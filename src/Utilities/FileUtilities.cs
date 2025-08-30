using System;
using System.Collections.Generic;
using System.Diagnostics;

namespace WowCyborg.Utilities
{
    public static class FileUtilities
    {
        public static bool OpenTextFile(string path)
        {
            var editors = new List<string> {"code", "notepad" };

            foreach (var editor in editors)
            {
                try
                {
                    var process = Process.Start(editor, path);
                    process.Close();

                    return true;
                }
                catch (Exception ex)
                {
                
                }
             }

            return false;
        }
    }
}
