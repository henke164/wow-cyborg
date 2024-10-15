using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using WowCyborg;
using WowCyborg.Models;

namespace WowCyborg
{
    public class PluginLoader
    {
        public static IList<PluginBase> GetPlugins(ApplicationSettings settings)
        {
            var files = Directory.GetFiles(AppDomain.CurrentDomain.BaseDirectory);
            var plugins = new List<PluginBase>();

            foreach (var file in files.Where(f => f.Contains(".dll")))
            {
                try
                {
                    var dll = Assembly.LoadFile(file);

                    foreach (var type in dll.GetExportedTypes())
                    {
                        if (type.Name == "Plugin")
                        {
                            plugins.Add((PluginBase)Activator.CreateInstance(type, new object[] { settings }));
                            Console.WriteLine("Loaded addon:" + type.Namespace);
                        }
                    }
                }
                catch(Exception ex)
                {

                }
            }

            return plugins;
        }
    }
}
