using Newtonsoft.Json;
using System;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using WowCyborg.Core;
using WowCyborg.PluginUtilities;

namespace ServerController
{
    class ServerManager
    {
        private string ipAddress = "127.0.0.1";

        private BotApi _botApi;

        private HttpListener _listener;

        public ServerManager(Bot bot)
        {
            _botApi = new BotApi(bot);
        }

        public void StartServer()
        {
            _listener = new HttpListener();
            _listener.Prefixes.Add($"http://{ipAddress}/");

            _listener.Start();
            Logger.Log($"Server successfully started, GET examples:\r\n" +
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
                    catch (Exception ex)
                    {
                        StopServer();
                        break;
                    }
                }
            });
        }

        private void WriteToResponse(HttpListenerContext context, string content)
        {
            var response = context.Response;
            response.Headers.Add("Access-Control-Allow-Origin", "*");

            var buffer = Encoding.UTF8.GetBytes(content);
            response.ContentLength64 = buffer.Length;
            var output = response.OutputStream;
            output.Write(buffer, 0, buffer.Length);
            output.Close();
        }

        private string HandleHTTPRequest(string rawUrl)
        {
            if (rawUrl == "/currentPosition")
            {
                var currentTransform = _botApi.GetCurrentTransform();
                if (currentTransform == null)
                {
                    return JsonConvert.SerializeObject(new
                    {
                        error = "Location not found"
                    });
                }

                return JsonConvert.SerializeObject(currentTransform);
            }
            else if (rawUrl.IndexOf("/moveTo?") == 0)
            {
                try
                {
                    var xParam = Regex.Match(rawUrl, @"(x)\=([^&]+)").Value.Split('=')[1];
                    var zParam = Regex.Match(rawUrl, @"(z)\=([^&]+)").Value.Split('=')[1];

                    var x = float.Parse(xParam.Replace('.', ','));
                    var z = float.Parse(zParam.Replace('.', ','));
                    _botApi.MoveTo(x, z);

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
                    _botApi.FaceTowards(x, z);

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

        public void StopServer()
        {
            if (_listener == null || !_listener.IsListening)
            {
                Logger.Log("Server is not running.", ConsoleColor.Red);
                return;
            }

            _listener.Stop();
            Logger.Log("Server stopped", ConsoleColor.Green);
        }
    }
}
