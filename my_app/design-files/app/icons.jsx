// teleBabies — Icons (stroke-based, friendly, custom)
// All icons are 24x24 viewBox, currentColor, configurable via size & strokeWidth

const Icon = ({ size = 22, strokeWidth = 2, children, style = {} }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none"
    stroke="currentColor" strokeWidth={strokeWidth}
    strokeLinecap="round" strokeLinejoin="round"
    style={{ flexShrink: 0, ...style }}>
    {children}
  </svg>
);

const I = {
  Home:    p => <Icon {...p}><path d="M3 11l9-8 9 8" /><path d="M5 10v10h14V10" /><path d="M10 20v-5h4v5" /></Icon>,
  Search:  p => <Icon {...p}><circle cx="11" cy="11" r="7" /><path d="m20 20-3.5-3.5" /></Icon>,
  Heart:   p => <Icon {...p}><path d="M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.5A4 4 0 0 1 19 10c0 5.5-7 10-7 10z" /></Icon>,
  Bag:     p => <Icon {...p}><path d="M5 8h14l-1 12H6L5 8z" /><path d="M9 8V5a3 3 0 0 1 6 0v3" /></Icon>,
  User:    p => <Icon {...p}><circle cx="12" cy="8" r="4" /><path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8" /></Icon>,
  Filter:  p => <Icon {...p}><path d="M3 5h18" /><path d="M6 12h12" /><path d="M9 19h6" /></Icon>,
  Plus:    p => <Icon {...p}><path d="M12 5v14M5 12h14" /></Icon>,
  Minus:   p => <Icon {...p}><path d="M5 12h14" /></Icon>,
  Close:   p => <Icon {...p}><path d="M6 6l12 12M18 6 6 18" /></Icon>,
  Check:   p => <Icon {...p}><path d="M5 12.5 10 17l9-10" /></Icon>,
  ChevronR:p => <Icon {...p}><path d="m9 6 6 6-6 6" /></Icon>,
  ChevronL:p => <Icon {...p}><path d="m15 6-6 6 6 6" /></Icon>,
  ChevronD:p => <Icon {...p}><path d="m6 9 6 6 6-6" /></Icon>,
  ChevronU:p => <Icon {...p}><path d="m6 15 6-6 6 6" /></Icon>,
  Bell:    p => <Icon {...p}><path d="M6 16V11a6 6 0 0 1 12 0v5l1.5 2H4.5L6 16z" /><path d="M10 21h4" /></Icon>,
  Star:    p => <Icon {...p}><path d="m12 3 2.7 5.7 6.3.9-4.5 4.4 1 6.3-5.5-3-5.5 3 1-6.3L3 9.6l6.3-.9L12 3z" /></Icon>,
  Truck:   p => <Icon {...p}><rect x="2" y="7" width="11" height="9" rx="1" /><path d="M13 10h5l3 3v3h-8" /><circle cx="7" cy="18" r="2" /><circle cx="17" cy="18" r="2" /></Icon>,
  Box:     p => <Icon {...p}><path d="M3 7l9-4 9 4-9 4-9-4z" /><path d="M3 7v10l9 4V11" /><path d="M21 7v10l-9 4" /></Icon>,
  MapPin:  p => <Icon {...p}><path d="M12 21s7-7 7-12a7 7 0 0 0-14 0c0 5 7 12 7 12z" /><circle cx="12" cy="9" r="2.5" /></Icon>,
  Camera:  p => <Icon {...p}><path d="M4 8h3l2-2h6l2 2h3v11H4z" /><circle cx="12" cy="13" r="3.5" /></Icon>,
  Upload:  p => <Icon {...p}><path d="M12 16V4" /><path d="m7 9 5-5 5 5" /><path d="M5 18v2h14v-2" /></Icon>,
  Tag:     p => <Icon {...p}><path d="M3 12V4h8l10 10-8 8L3 12z" /><circle cx="8" cy="8" r="1.5" /></Icon>,
  Trash:   p => <Icon {...p}><path d="M4 7h16" /><path d="M9 7V4h6v3" /><path d="M6 7l1 13h10l1-13" /></Icon>,
  Edit:    p => <Icon {...p}><path d="M4 20h4l11-11-4-4L4 16v4z" /></Icon>,
  Eye:     p => <Icon {...p}><path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z" /><circle cx="12" cy="12" r="3" /></Icon>,
  Phone:   p => <Icon {...p}><path d="M5 4h4l2 5-2 1a11 11 0 0 0 5 5l1-2 5 2v4a2 2 0 0 1-2 2A16 16 0 0 1 3 6a2 2 0 0 1 2-2z" /></Icon>,
  Mail:    p => <Icon {...p}><rect x="3" y="6" width="18" height="13" rx="2" /><path d="m4 8 8 6 8-6" /></Icon>,
  Logout:  p => <Icon {...p}><path d="M14 4h4a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-4" /><path d="m10 8-4 4 4 4" /><path d="M6 12h12" /></Icon>,
  Globe:   p => <Icon {...p}><circle cx="12" cy="12" r="9" /><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18" /></Icon>,
  Sparkle: p => <Icon {...p}><path d="M12 3v6M12 15v6M3 12h6M15 12h6" /></Icon>,
  Menu:    p => <Icon {...p}><path d="M4 7h16M4 12h16M4 17h16" /></Icon>,
  Settings:p => <Icon {...p}><circle cx="12" cy="12" r="3" /><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1A1.7 1.7 0 0 0 9 19.4a1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1A1.7 1.7 0 0 0 4.6 9a1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z" /></Icon>,
  ArrowR:  p => <Icon {...p}><path d="M5 12h14M13 5l7 7-7 7" /></Icon>,
  ArrowL:  p => <Icon {...p}><path d="M19 12H5M11 19l-7-7 7-7" /></Icon>,
  Refresh: p => <Icon {...p}><path d="M3 12a9 9 0 0 1 15-6.7L21 8" /><path d="M21 3v5h-5" /><path d="M21 12a9 9 0 0 1-15 6.7L3 16" /><path d="M3 21v-5h5" /></Icon>,
  Clock:   p => <Icon {...p}><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></Icon>,
  Image:   p => <Icon {...p}><rect x="3" y="4" width="18" height="16" rx="2" /><circle cx="9" cy="10" r="1.5" /><path d="m4 19 5-5 4 4 3-3 4 4" /></Icon>,
  Wallet:  p => <Icon {...p}><rect x="3" y="6" width="18" height="13" rx="2" /><path d="M3 10h18" /><circle cx="16" cy="14.5" r="1.5" /></Icon>,
  Smile:   p => <Icon {...p}><circle cx="12" cy="12" r="9" /><circle cx="9" cy="10" r="0.8" fill="currentColor" /><circle cx="15" cy="10" r="0.8" fill="currentColor" /><path d="M8.5 14a4 4 0 0 0 7 0" /></Icon>,
  Gift:    p => <Icon {...p}><rect x="3" y="9" width="18" height="11" rx="1" /><path d="M3 13h18M12 9v11" /><path d="M12 9c-2 0-4-1.5-4-3a2 2 0 0 1 4 0c0 1.5-2 3-4 3M12 9c2 0 4-1.5 4-3a2 2 0 0 0-4 0c0 1.5 2 3 4 3" /></Icon>,
  Receipt: p => <Icon {...p}><path d="M5 3h14v18l-3-2-2 2-2-2-2 2-2-2-3 2V3z" /><path d="M8 8h8M8 12h8M8 16h5" /></Icon>,
  Pkg:     p => <Icon {...p}><path d="M3 8h18v12H3z" /><path d="M3 8l3-4h12l3 4" /><path d="M9 12h6" /></Icon>,
  Shirt:   p => <Icon {...p}><path d="M4 7l4-3h2a2 2 0 0 0 4 0h2l4 3-3 4-2-1v10H7V10L5 11 4 7z" /></Icon>,
  Stars:   p => <Icon {...p}><path d="m6 4 1 2 2 1-2 1-1 2-1-2-2-1 2-1 1-2z" /><path d="m17 12 1.3 2.7 2.7 1.3-2.7 1.3-1.3 2.7-1.3-2.7-2.7-1.3 2.7-1.3L17 12z" /><path d="m13 4 .8 1.6 1.6.4-1.6.8L13 8.4l-.8-1.6-1.6-.8 1.6-.4L13 4z" /></Icon>,
  Globe2:  p => <Icon {...p}><circle cx="12" cy="12" r="9" /><path d="M12 3a9 9 0 0 1 0 18M12 3a9 9 0 0 0 0 18M3 12h18" /></Icon>,
  Pencil:  p => <Icon {...p}><path d="M4 20h4l11-11-4-4L4 16v4z" /><path d="m14 6 4 4" /></Icon>,
  ThumbsUp:p => <Icon {...p}><path d="M7 11v9H4v-9h3z" /><path d="M7 11l4-7a2 2 0 0 1 2 2v4h5a2 2 0 0 1 2 2.3l-1.2 6A2 2 0 0 1 16.8 20H7" /></Icon>,
  ChevronDown: p => <Icon {...p}><path d="m6 9 6 6 6-6" /></Icon>,

  // Category icons — playful, filled-friendly
  CatAll:     p => <Icon {...p}><path d="m12 3 2.4 5.4 5.6.8-4.2 4 1 5.8L12 16.5 7.2 19l1-5.8L4 9.2l5.6-.8L12 3z" /></Icon>,
  CatGirls:   p => <Icon {...p}><path d="M9 4h6l-1 4h2l-2 7h-1v6h-4v-6H8l-2-7h2L7 4z" /></Icon>,
  CatBoys:    p => <Icon {...p}><path d="M5 7l3-3h2a2 2 0 0 0 4 0h2l3 3-2 4-2-1v9H7v-9l-2 1-2-4z" /></Icon>,
  CatNewborn: p => <Icon {...p}><path d="M10 3h4v3h-4z" /><path d="M9 6h6l1 3H8z" /><path d="M7 9h10l-1 11H8L7 9z" /><path d="M11 13h2" /></Icon>,
  CatShoes:   p => <Icon {...p}><path d="M3 16l1-7 5 1 4-3 3 1 1 3 4 1v4l-1 2H4l-1-2z" /><path d="M7 13h2M11 13h2" /></Icon>,
  CatSale:    p => <Icon {...p}><rect x="4" y="9" width="16" height="11" rx="1.5" /><path d="M4 13h16M12 9v11" /><path d="M12 9c-2 0-3.5-1.2-3.5-2.5a1.8 1.8 0 0 1 3.5-.5c0 1.5-3.5 3-3.5 3M12 9c2 0 3.5-1.2 3.5-2.5a1.8 1.8 0 0 0-3.5-.5c0 1.5 3.5 3 3.5 3" /></Icon>,
};

window.I = I;
window.TBIcon = Icon;
