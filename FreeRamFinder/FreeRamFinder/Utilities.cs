using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FreeRamFinder
{
    internal static class Utilities
    {
        // Used to help create the AllSmwFreeRamAddresses.txt
        // reference: https://www.smwcentral.net/?p=memorymap&game=smw&u=0&address=&sizeOperation=%3D&sizeValue=&region[]=ram&type=Empty&description=
        public static void ExportAddressRange(string projectRootDirectory, string hex, int numBytes)
        {
            TextWriter tw = new StreamWriter(projectRootDirectory + "output.txt", true);
            int intValue = int.Parse(hex, System.Globalization.NumberStyles.HexNumber);
            for (int i = 0; i < numBytes; i++)
            {
                // Console.WriteLine(intValue.ToString("X"));
                tw.WriteLine(intValue.ToString("X"));
                intValue += 1;
            }
            tw.Close();
        }
    }
}
