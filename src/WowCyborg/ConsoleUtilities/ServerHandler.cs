using Newtonsoft.Json;
using System;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using WowCyborg.Utilities;

namespace WowCyborg.ConsoleUtilities
{
    public static class ServerHandler
    {
        private static HttpListener _listener;

        private static string ipAddress = "127.0.0.1";

        public static void HandleInput(string[] parameters)
        {
            var commandParameters = parameters.ToList().Skip(1).ToList();

            if (commandParameters.Count() == 0)
            {
                Program.ShowHelp();
                return;
            }

            switch (commandParameters[0])
            {
                case "start":
                    StartServer();
                    break;
                case "stop":
                    StopServer();
                    break;
            }
        }

        private static void StartServer()
        {
            _listener = new HttpListener();
            _listener.Prefixes.Add($"http://{ipAddress}/");

            _listener.Start();
            Program.Log($"Server successfully started, GET examples:\r\n" +
                $"http://{ipAddress}/currentPosition\r\n" +
                $"http://{ipAddress}/moveTo?x=0.43&z=0.51\r\n", ConsoleColor.Green);

            Task.Run(() => {
                while (true)
                {
                    try
                    {
                        var context = _listener.GetContext();
                        var request = context.Request;

                        var responseString = HandleHTTPRequest(request.RawUrl);

                        WriteToResponse(context, responseString);
                    }
                    catch(Exception ex)
                    {
                        StopServer();
                        break;
                    }
                }
            });
        }

        private static void WriteToResponse(HttpListenerContext context, string content)
        {
            var response = context.Response;
            response.Headers.Add("Access-Control-Allow-Origin", "*");

            var buffer = Encoding.UTF8.GetBytes(content);
            response.ContentLength64 = buffer.Length;
            var output = response.OutputStream;
            output.Write(buffer, 0, buffer.Length);
            output.Close();
        }

        private static string HandleHTTPRequest(string rawUrl)
        {
            if (rawUrl == "/currentPosition")
            {
                if (Program.BotRunner.CurrentTransform == null)
                {
                    return JsonConvert.SerializeObject(new
                    {
                        error = "Location not found"
                    });
                }

                return JsonConvert.SerializeObject(new
                {
                    x = Program.BotRunner.CurrentTransform.Position.X,
                    z = Program.BotRunner.CurrentTransform.Position.Z,
                    zone = Program.BotRunner.CurrentTransform.ZoneId
                });
            }
            else if (rawUrl.IndexOf("/moveTo?") == 0)
            {
                try
                {
                    var xParam = Regex.Match(rawUrl, @"(x)\=([^&]+)").Value.Split('=')[1];
                    var zParam = Regex.Match(rawUrl, @"(z)\=([^&]+)").Value.Split('=')[1];

                    var x = float.Parse(xParam.Replace('.', ','));
                    var z = float.Parse(zParam.Replace('.', ','));
                    Program.BotRunner.MoveTo(new Vector3(x, 0, z));

                    return JsonConvert.SerializeObject(new
                    {
                        message = "ok"
                    });
                }
                catch
                {
                    return JsonConvert.SerializeObject(new
                    {
                        error = "Wrong parameters"
                    });
                }
            }
            else if (rawUrl.IndexOf("/face?") == 0)
            {
                try
                {
                    var xParam = Regex.Match(rawUrl, @"(x)\=([^&]+)").Value.Split('=')[1];
                    var zParam = Regex.Match(rawUrl, @"(z)\=([^&]+)").Value.Split('=')[1];

                    var x = float.Parse(xParam.Replace('.', ','));
                    var z = float.Parse(zParam.Replace('.', ','));
                    Program.BotRunner.FaceTowards(new Vector3(x, 0, z));

                    return JsonConvert.SerializeObject(new
                    {
                        message = "ok"
                    });
                }
                catch
                {
                    return JsonConvert.SerializeObject(new
                    {
                        error = "Wrong parameters"
                    });
                }
            }

            return "Empty result";
        }

        private static void StopServer()
        {
            if (_listener == null || !_listener.IsListening)
            {
                Program.Log("Server is not running.", ConsoleColor.Red);
                return;
            }

            _listener.Stop();
            Program.Log("Server stopped", ConsoleColor.Green);
        }
    }
}
