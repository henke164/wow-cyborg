using System;

namespace WowCyborg.PluginUtilities
{
    public class Logger
    {
        public static void Log(string str, ConsoleColor color = ConsoleColor.White, bool inLine = false)
        {
            Console.ForegroundColor = color;
            if (inLine)
            {
                Console.Write(str);
                return;
            }
            Console.WriteLine(str);
        }
    }
}
