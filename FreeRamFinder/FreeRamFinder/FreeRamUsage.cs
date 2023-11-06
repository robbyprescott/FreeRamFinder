using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FreeRamFinder
{
    public enum FreeRamType
    {
        Literal,
        VariablePlusConstant,
        VariablePlusVariable,
    }

    public class FreeRamUsage
    {
        public string address;

        public string filePath;

        public int lineNumber;

        public string howItAppears;

        public FreeRamType type;

        public FreeRamUsage(string address, string filePath, int lineNumber, string howItAppears, FreeRamType type)
        {
            this.address = address;
            this.filePath = filePath;
            this.lineNumber = lineNumber;
            this.howItAppears = howItAppears;
            this.type = type;
        }

        public override string ToString()
        {
            return $"{address} used in {filePath} at line {lineNumber} as \"{howItAppears}\"";
        }
    }
}
