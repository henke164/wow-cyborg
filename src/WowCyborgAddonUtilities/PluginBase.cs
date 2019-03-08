namespace WowCyborgAddonUtilities
{
    public abstract class PluginBase
    {
        public abstract bool HandleInput(string command, string[] args);

        public abstract void ShowCommands();
    }
}
