namespace WowCyborgAddonUtilities
{
    public abstract class PluginBase
    {
        protected ApplicationSettings Settings;

        public PluginBase(ApplicationSettings settings)
        {
            Settings = settings;
        }

        public abstract bool HandleInput(string command, string[] args);

        public abstract void ShowCommands();
    }
}
