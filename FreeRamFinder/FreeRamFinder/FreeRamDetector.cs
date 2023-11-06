using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace FreeRamFinder
{
    public class FreeRamDetector
    {
        List<string> freeRamAddresses = new List<string>();
        public List<string> ignoredLines { get; } = new List<string>();
        string prefixMask = "7E00XX"; // default mask for smw

        public FreeRamDetector() {}

        public FreeRamDetector(string prefixMask) 
        {
            this.prefixMask = prefixMask;
        }

        public void LoadInFreeRamAddressesFromFile(string filePath)
        {
            using (StreamReader read = new StreamReader(filePath))
            {
                string line;
                while ((line = read.ReadLine()) != null)
                {
                    if (string.IsNullOrEmpty(line))
                    {
                        continue; // don't add the blank lines (free ram chunk delimiters)
                    }
                    freeRamAddresses.Add(line);
                }
            }

            freeRamAddresses.Sort();
        }

        public List<FreeRamUsage> FindAllFreeRamUsageInFile(string rootDirectory, string filePathRelativeToRoot)
        {
            List<string> fileLines = new List<string>();
            var freeRamUsageList = new List<FreeRamUsage>();
            var freeRamVariableLookup = new Dictionary<string, string>();
            // add all lines of the file and remove comments
            using (StreamReader read = new StreamReader($"{rootDirectory}{filePathRelativeToRoot}"))
            {
                string line;
                while ((line = read.ReadLine()) != null)
                {
                    if (line.StartsWith(';'))
                        continue; // skip comment

                    string lineWithCommentRemoved = line.Contains(';') ? line.Substring(0, line.IndexOf(';')) : line;
                    fileLines.Add(lineWithCommentRemoved.Trim());
                }
            }

            // filter out all table addresses
            for (int i = 0; i < fileLines.Count; i++)
            {
                string line = fileLines[i];
                char[] delimeters = { ' ', '|', '[', ']', '(', ')', '\t', '+', '-' };
                var tokens = line.Split(delimeters).ToList();
                tokens.RemoveAll(x => string.IsNullOrEmpty(x) || string.IsNullOrWhiteSpace(x));

                foreach (string token in tokens)
                {
                    // only consider tokens with commas
                    if (!token.Contains(','))
                        continue;

                    var subTokens = token.Split(',');

                    bool isTableFormat = true;
                    foreach (var subToken in subTokens)
                    {
                        // each item separated by a comma must start with a $ or ! to be a table
                        if (!subToken.StartsWith('$') && !subToken.StartsWith('!'))
                        {
                            isTableFormat = false;
                            break;
                        }
                    }

                    if (isTableFormat)
                    {
                        ignoredLines.Add($"ignored: {line} | line {i + 1} in: {Path.GetFileNameWithoutExtension(filePathRelativeToRoot)}");
                        fileLines[i] = string.Empty; // assign as empty string to remove all at once in the next step -- more efficient than removing as you go
                    }
                }
            }

            // remove all empty strings assigned in previous step
            fileLines.RemoveAll(x => string.IsNullOrEmpty(x));

            // find all literal occurrences in file

            for (int lineIndex = 0; lineIndex < fileLines.Count; lineIndex++)
            {
                var line = fileLines[lineIndex];
                char[] delimeters = { ' ', '|', '[', ']', '(', ')', '\t', ','};
                var tokens = line.Split(delimeters).ToList();
                tokens.RemoveAll(x => string.IsNullOrEmpty(x) || string.IsNullOrWhiteSpace(x));

                bool stopProcessingLine = false;
                for (int i = 0; i < tokens.Count; i++)
                {
                    var token = tokens[i];
                    if (token.StartsWith(";") || token == "db" || token.StartsWith("#"))
                    {
                        stopProcessingLine = true;
                        break; // break out from the current line immediately
                    }

                    if (token.EndsWith(";"))
                    {
                        stopProcessingLine = true; // break out from the current line after processing this token. ex: still want to process "$7C;"
                        token = token.Substring(0, token.Length - 1);
                    }

                    bool isFreeRamAddress = IsFreeRamAddress(token);
                    if (isFreeRamAddress)
                    {
                        var addressHex = MapToActualAddress(token);
                        var newFreeRamUsage = new FreeRamUsage(addressHex, filePathRelativeToRoot, lineIndex + 1, token, FreeRamType.Literal);
                        freeRamUsageList.Add(newFreeRamUsage);

                        // determine if the address is being used in assignment
                        bool isAddressBeingDeclared = i >= 2 && tokens[i - 1] == "=" && tokens[i - 2].StartsWith("!");
                        if (isAddressBeingDeclared && !freeRamVariableLookup.ContainsKey(tokens[i - 2]))
                        {
                            freeRamVariableLookup.Add(tokens[i - 2], addressHex);
                        }
                    }
                }
                if (stopProcessingLine)
                {
                    continue;
                }
            }

            for (int lineIndex = 0; lineIndex < fileLines.Count; lineIndex++)
            {
                string line = fileLines[lineIndex];
                char[] delimeters = { ' ', '|', '[', ']', '(', ')', ';', '\t'}; // note that comma, +, and - are removed for this run through
                var tokens = line.Split(delimeters).ToList();
                foreach (var token in tokens)
                {
                    var variableFreeRamAddressFoundInToken = freeRamVariableLookup.Keys.ToList().Find(x => token.Contains(x));
                    var pattern = new Regex(@"\+([0-9]+)");
                    var matches = pattern.Matches(token);
                    var constantBeingAdded = matches.Count > 0 ? matches[0].Groups[1].Value : null;

                    // variable + constant case
                    if (variableFreeRamAddressFoundInToken != null && constantBeingAdded != null)
                    {
                        var hexAddress = freeRamVariableLookup[variableFreeRamAddressFoundInToken];
                        int freeRamInt = int.Parse(hexAddress, System.Globalization.NumberStyles.HexNumber); // convert to decimal
                        int constantInt = int.Parse(constantBeingAdded);
                        int resolvedAddressInt = freeRamInt + constantInt;
                        string resolvedAddress = "$" + resolvedAddressInt.ToString("X"); // convert back to hex after adding

                        // discern if the new address is a freeram address
                        bool isFreeRamAddress = IsFreeRamAddress(resolvedAddress);
                        if (isFreeRamAddress)
                        {
                            string appearsAs = $"{variableFreeRamAddressFoundInToken}+{constantBeingAdded}";
                            var newFreeRamUsage = new FreeRamUsage(MapToActualAddress(resolvedAddress), filePathRelativeToRoot, lineIndex + 1, appearsAs, FreeRamType.VariablePlusConstant);
                            freeRamUsageList.Add(newFreeRamUsage);
                        }
                    }

                    // check for variable + variable case !freeram,x
                    pattern = new Regex(@",(\w+)");
                    matches = pattern.Matches(token);
                    var variableBeingAdded = matches.Count > 0 ? matches[0].Groups[1].Value : null;
                    if (variableFreeRamAddressFoundInToken != null && variableBeingAdded != null)
                    {
                        var newFreeRamUsage = new FreeRamUsage(MapToActualAddress(freeRamVariableLookup[variableFreeRamAddressFoundInToken] + " variation"), filePathRelativeToRoot, lineIndex + 1, token, FreeRamType.VariablePlusVariable);
                        freeRamUsageList.Add(newFreeRamUsage);
                    }
                }
            }
            return freeRamUsageList;
        }

        public void PrintAllFreeRamAddresses()
        {
            foreach (var address in freeRamAddresses)
            {
                Console.WriteLine(address);
            }
        }

        public bool IsFreeRamAddress(string token)
        {
            if (string.IsNullOrEmpty(token) || !token.StartsWith("$"))
            {
                // is not address
                return false;
            }

            var address = MapToActualAddress(token);

            if (address.Length != 6)
            {
                // all addresses should be 6 after mapping
                return false;
            }

            if (!address.StartsWith("7E") && !address.StartsWith("7F"))
            {
                // all free ram addresses in smw start with 7E or 7F so we don't even have to look at the list
                return false;
            }
            
            bool containsToken = 0 < freeRamAddresses.BinarySearch(address);
            return containsToken;

            
        }

        public string MapToActualAddress(string token)
        {
            // remove $ prefixing the hex value
            if (token.StartsWith("$"))
            {
                token = token.Substring(1);
            }

            // account for shorthand
            if (token.Length == 2)
            {
                token = $"{prefixMask.Substring(0, 4)}{token}";
            }

            if (token.Length == 4)
            {
                token = $"{prefixMask.Substring(0, 2)}{token}";
            }

            return token;
        }
    }
}
