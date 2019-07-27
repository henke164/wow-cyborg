using System.Windows.Forms;

namespace WowCyborg.Core.Models
{
    public class KeyPressRequest
    {
        public Keys Key { get; set; }
        public Keys ModifierKey { get; set; }
    }
}
