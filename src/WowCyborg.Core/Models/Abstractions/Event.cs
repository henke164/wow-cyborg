﻿using System;

namespace WowCyborg.Core.Models.Abstractions
{
    public class Event
    {
        public IntPtr HWnd { get; set; }

        public string Name { get; set; }

        public object Data { get; set; }
    }
}
