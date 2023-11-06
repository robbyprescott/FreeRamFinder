using FreeRamFinder;

// configurable environment variables
// string projectRootDirectory = "C:\\Users\\Robby\\Projects\\FreeRamFinder\\FreeRamFinder\\FreeRamFinder\\FakeProject\\";
// string projectRootDirectory = "C:\\Users\\Robby\\Projects\\FreeRamFinder\\FreeRamFinder\\FreeRamFinder\\VariableInjectionProject\\";
// string projectRootDirectory = "C:\\Users\\Robby\\Projects\\FreeRamFinder\\FreeRamFinder\\FreeRamFinder\\MeanFiles\\";
string currentDirectoryPath = Directory.GetCurrentDirectory();
string allFreeRamAddressesFilePath = $"{currentDirectoryPath}\\AllSmwFreeRamAddresses.txt";
string prefixMask = "7E00XX"; // change this for SA-1

// derived & acquired environment variables

Console.WriteLine("Please drag-in the smw project's root directory into this window and hit [Enter] to find the freeram conflicts:");
var projectRootDirectory = Console.ReadLine();
if (string.IsNullOrEmpty(projectRootDirectory))
{
    throw new Exception("Error: the project root directory cannot be null. Please type-out or drag-in an actual directory path.");
}

var now = DateTime.Now.ToString("yyyy'-'MM'-'dd'_'hh'.'mm'.'ss''tt");
string outputDirectory = $"{currentDirectoryPath}\\__output__\\{now}";
Directory.CreateDirectory(outputDirectory);


Console.WriteLine("Starting to Find FreeRam Address Conflicts. This may take a few seconds...");

// main logic 
DateTime startTime = DateTime.Now;
var cataloger = new FreeRamCataloger(projectRootDirectory);
cataloger.FindAllFreeRamUsages(allFreeRamAddressesFilePath, prefixMask);
cataloger.GroupFreeRamUsagesByAddress();

//cataloger.PrintAllFreeRamUsages();

cataloger.WriteFreeRamConflictsToFile(outputDirectory);
cataloger.WriteLiteralFreeRamUsagesToFile(outputDirectory);
cataloger.WriteVariableFreeRamUsagesToFile(outputDirectory);
cataloger.WriteUntracableFreeRamUsagesToFile(outputDirectory);
cataloger.WriteIgnoredLines(outputDirectory);
DateTime endTime = DateTime.Now;
TimeSpan totalTime = endTime - startTime;
Console.WriteLine($"\nTotal processing time: {totalTime}");
Console.WriteLine("Script completed successfully. Check the __output__ directory for the results.");
Console.ReadKey();