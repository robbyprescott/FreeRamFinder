using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;

namespace FreeRamFinder
{
    public class FreeRamCataloger
    {
        List<FreeRamUsage> freeRamUsages = new List<FreeRamUsage>();
        List<IGrouping<string, FreeRamUsage>> freeRamUsageHistogramByFile = new List<IGrouping<string, FreeRamUsage>>();
        string projectRootDirectory;
        List<string> asmFilePaths;
        List<string> ignoredLines;

        public FreeRamCataloger(string projectRootDirectory)
        {
            this.projectRootDirectory = projectRootDirectory;
            asmFilePaths = GetAllAsmFilePathsRelativeToRoot();
        }

        public List<string> GetAllAsmFilePathsRelativeToRoot()
        {
            var allAbsolutePaths = Directory.GetFiles(projectRootDirectory, "*.asm", SearchOption.AllDirectories).ToList();
            var allFilePathsRelativeToRoot = allAbsolutePaths.Select(x => x.Substring(projectRootDirectory.Length)).ToList();
            return allFilePathsRelativeToRoot;
        }

        public void FindAllFreeRamUsages(string freeRamAddressesFilePath, string prefixMask)
        {
            var freeRamDetector = new FreeRamDetector(prefixMask);
            freeRamDetector.LoadInFreeRamAddressesFromFile(freeRamAddressesFilePath);

            Console.WriteLine($"Finding all freeram usages for all {asmFilePaths.Count} asm files in rom...");
            foreach (var path in asmFilePaths)
            {
                var usagesInFile = freeRamDetector.FindAllFreeRamUsageInFile(projectRootDirectory, path);
                freeRamUsages.AddRange(usagesInFile);
            }

            ignoredLines = freeRamDetector.ignoredLines;

            // order by freeram address
            Console.WriteLine("Ordering freeram usages found by address, filepath, linenumber...");
            freeRamUsages = freeRamUsages
                .OrderBy(x => x.address)
                .ThenBy(x => x.filePath)
                .ThenBy(x => x.lineNumber)
                .ToList();
        }

        public void GroupFreeRamUsagesByAddress()
        {
            Console.WriteLine("Grouping freeram addresses to check for conflicts...");
            // remove multiple occurences of the same freeram address in the same file
            var distinctUsagesInFile = freeRamUsages.GroupBy(x => new { x.filePath, x.address }).Select(x => x.First()).ToList();

            // put the occurences that use the same freeram address into their own lists
            var groupedByAddress = distinctUsagesInFile.GroupBy(x => x.address).ToList();

            freeRamUsageHistogramByFile = groupedByAddress.OrderByDescending(x => x.Count()).ToList();
        }

        public void PrintFreeRamConflicts()
        {
            if (freeRamUsageHistogramByFile.Find(x => x.Count() > 1) == null)
            {
                // couldn't find any conflicts
                Console.WriteLine($"No freeram conflicts found!");
            }

            Console.WriteLine($"Freeram Conflicts Output:");

            foreach (var group in freeRamUsageHistogramByFile)
            {
                if (group.Count() == 1)
                {
                    // it only occured once -- not a conflict
                    continue;
                }
                Console.WriteLine($"\n  Freeram conflict {group.Key} was found {group.Count()} times:");

                foreach (var usage in group)
                {
                    Console.WriteLine("    " + usage.ToString());
                }
            }
        }

        public void PrintAllFreeRamUsages()
        {
            Console.WriteLine();
            Console.WriteLine("\nAll Freeram Usage Output: ");

            Console.WriteLine("\n  Literal Address Usage:");
            foreach (var usage in freeRamUsages.Where(x => x.type == FreeRamType.Literal))
            {
                Console.WriteLine("    " + usage.ToString());
            }

            if (freeRamUsages.Where(x => x.type == FreeRamType.VariablePlusConstant).ToList().Count > 0)
            {
                Console.WriteLine("\n  Variable Address Usage:");
                foreach (var usage in freeRamUsages.Where(x => x.type == FreeRamType.VariablePlusConstant))
                {
                    Console.WriteLine("    " + usage.ToString());
                }
            }

            if (freeRamUsages.Where(x => x.type == FreeRamType.VariablePlusVariable).ToList().Count > 0)
            {
                Console.WriteLine("\nUntraceable Variations Stem From These Addresses:");
                Console.WriteLine("  ** These are just a warning ... a list of some files to keep your eye on.");
                Console.WriteLine("  ** Might need to manually verify that the following variations of ram addresses\n  ** aren't close in value to ones used in other cases in separate files listed.");
                Console.WriteLine("  ** If address comes close to other addresses listed, consider changing the root\n  ** freeram address to another available address in the smw central freeram table.");
                Console.WriteLine("  --> https://www.smwcentral.net/?p=memorymap&game=smw&region[]=ram&type=Empty\n");

                foreach (var usage in freeRamUsages.Where(x => x.type == FreeRamType.VariablePlusVariable))
                {
                    Console.WriteLine("    " + usage.ToString());
                }
            }
        }

        public void WriteFreeRamConflictsToFile(string dirPath)
        {
            string filePath = Path.Combine(dirPath, "FreeRamConflicts.txt");
            Console.WriteLine($"Creating and writing to new file: {filePath}");
            using (StreamWriter outputFile = new StreamWriter(filePath, true))
            {
                if (freeRamUsageHistogramByFile.Find(x => x.Count() > 1) == null)
                {
                    // couldn't find any conflicts
                    outputFile.WriteLine($"No freeram conflicts found!");
                }

                foreach (var group in freeRamUsageHistogramByFile)
                {
                    if (group.Count() == 1)
                    {
                        // it only occured once -- not a conflict
                        continue;
                    }
                    outputFile.WriteLine($"Freeram conflict {group.Key} was found {group.Count()} times:");

                    foreach (var usage in group)
                    {
                        outputFile.WriteLine("    " + usage.ToString());
                    }

                    outputFile.WriteLine(); // spacing
                }
            }
        }

        public void WriteLiteralFreeRamUsagesToFile(string dirPath)
        {
            string filePath = Path.Combine(dirPath, "LiteralFreeramUsages.txt");
            Console.WriteLine($"Creating and writing to new file: {filePath}");
            using (StreamWriter outputFile = new StreamWriter(filePath, true))
            {
                outputFile.WriteLine("Literal Address Usage:");
                foreach (var usage in freeRamUsages.Where(x => x.type == FreeRamType.Literal))
                {
                    outputFile.WriteLine(usage.ToString());
                }
            }
        }

        public void WriteVariableFreeRamUsagesToFile(string dirPath)
        {
            string filePath = Path.Combine(dirPath, "VariableFreeramUsages.txt");
            Console.WriteLine($"Creating and writing to new file: {filePath}");
            using (StreamWriter outputFile = new StreamWriter(filePath, true))
            {
                outputFile.WriteLine("Variable Address Usage:");
                foreach (var usage in freeRamUsages.Where(x => x.type == FreeRamType.VariablePlusConstant))
                {
                    outputFile.WriteLine(usage.ToString());
                }
            }
        }

        public void WriteUntracableFreeRamUsagesToFile(string dirPath)
        {
            string filePath = Path.Combine(dirPath, "UntracableFreeramUsages.txt");
            Console.WriteLine($"Creating and writing to new file: {filePath}");
            using (StreamWriter outputFile = new StreamWriter(filePath, true))
            {
                outputFile.WriteLine("Untraceable Variations Stem From These Addresses:");
                outputFile.WriteLine("** These are just a warning ... a list of some files to keep your eye on.");
                outputFile.WriteLine("** Might need to manually verify that the following variations of ram addresses");
                outputFile.WriteLine("** aren't close in value to ones used in other cases in separate files listed.");
                outputFile.WriteLine("** If address comes close to other addresses listed, consider changing the root");
                outputFile.WriteLine("** freeram address to another available address in the smw central freeram table.");
                outputFile.WriteLine("--> https://www.smwcentral.net/?p=memorymap&game=smw&region[]=ram&type=Empty\n\n");

                foreach (var usage in freeRamUsages.Where(x => x.type == FreeRamType.VariablePlusVariable))
                {
                    outputFile.WriteLine(usage.ToString());
                }
            }
        }

        public void WriteIgnoredLines(string dirPath)
        {
            string filePath = Path.Combine(dirPath, "IgnoredLines.txt");
            Console.WriteLine($"Creating and writing to new file: {filePath}");
            using (StreamWriter outputFile = new StreamWriter(filePath, true))
            {
                outputFile.WriteLine("These lines were ignored because they are probably tables and would lead to false positives:\n");

                foreach (var line in ignoredLines)
                {
                    outputFile.WriteLine(line);
                }
            }
        }
    }
}
