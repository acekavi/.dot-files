vim.g.clipboard = {
  name = 'WLClipboard',
  copy = {
    ['+'] = '/usr/bin/wl-copy',
    ['*'] = '/usr/bin/wl-copy',
  },
  paste = {
    ['+'] = '/usr/bin/wl-paste',
    ['*'] = '/usr/bin/wl-paste',
  },
  cache_enabled = 0,
}