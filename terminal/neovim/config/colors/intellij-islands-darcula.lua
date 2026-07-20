-- Local scheme for matching IntelliJ's bundled Darcula editor palette more closely than third-party ports.
-- Islands Darcula is a JetBrains UI theme, so Neovim can only mirror the editor color scheme side.
vim.cmd("highlight clear")

if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.o.background = "dark"
vim.g.colors_name = "intellij-islands-darcula"
vim.opt.termguicolors = true

-- Values come from JetBrains' DefaultColorSchemesManager.xml Darcula scheme where an equivalent exists.
local colors = {
  bg = "#2b2b2b",
  bg_dark = "#232525",
  bg_panel = "#2b2d30",
  bg_gutter = "#313335",
  bg_popup = "#3c3f41",
  bg_hover = "#46484a",
  fg = "#a9b7c6",
  fg_dim = "#808080",
  fg_muted = "#606366",
  fg_bright = "#bbbbbb",
  selection = "#214283",
  selection_inactive = "#4c4f56",
  caret_row = "#323232",
  border = "#555555",
  indent = "#373737",
  orange = "#cc7832",
  green = "#6a8759",
  comment_green = "#629755",
  blue = "#6897bb",
  purple = "#9876aa",
  yellow = "#ffc66d",
  annotation = "#bbb529",
  red = "#cf5b56",
  red_bright = "#ff0000",
  vcs_added = "#629755",
  vcs_modified = "#6897bb",
  vcs_deleted = "#6c6c6c",
  vcs_unknown = "#d1675a",
}

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Map Neovim UI/plugin groups to the same limited palette so sidebars and popups stay close to IntelliJ.
local groups = {
  Normal = { fg = colors.fg, bg = colors.bg },
  NormalNC = { fg = colors.fg, bg = colors.bg },
  NormalFloat = { fg = colors.fg, bg = colors.bg_popup },
  FloatBorder = { fg = colors.border, bg = colors.bg_popup },
  FloatTitle = { fg = colors.fg_bright, bg = colors.bg_popup },
  ColorColumn = { bg = colors.bg_dark },
  Cursor = { fg = colors.bg, bg = colors.fg_bright },
  CursorLine = { bg = colors.caret_row },
  CursorLineNr = { fg = "#a4a3a3", bg = colors.bg_gutter },
  LineNr = { fg = colors.fg_muted, bg = colors.bg_gutter },
  SignColumn = { fg = colors.fg_muted, bg = colors.bg_gutter },
  FoldColumn = { fg = colors.fg_muted, bg = colors.bg_gutter },
  Folded = { fg = colors.fg_dim, bg = colors.bg_popup },
  VertSplit = { fg = colors.border, bg = colors.bg },
  WinSeparator = { fg = colors.border, bg = colors.bg },
  Visual = { bg = colors.selection },
  VisualNOS = { bg = colors.selection_inactive },
  Search = { fg = "#000000", bg = "#ffe055" },
  IncSearch = { fg = "#000000", bg = "#ff941a" },
  CurSearch = { fg = "#000000", bg = "#ff941a" },
  MatchParen = { fg = colors.fg_bright, bg = "#3b514d" },
  NonText = { fg = colors.fg_muted },
  Whitespace = { fg = "#606060" },
  SpecialKey = { fg = colors.fg_muted },
  Conceal = { fg = colors.fg_muted },
  Directory = { fg = colors.blue },
  Title = { fg = colors.yellow },
  ModeMsg = { fg = colors.fg_bright },
  MoreMsg = { fg = colors.green },
  Question = { fg = colors.green },
  WarningMsg = { fg = "#e69317" },
  ErrorMsg = { fg = colors.red_bright },
  MsgArea = { fg = colors.fg, bg = colors.bg },
  Pmenu = { fg = colors.fg, bg = colors.bg_popup },
  PmenuSel = { fg = colors.fg, bg = colors.selection },
  PmenuSbar = { bg = colors.bg_hover },
  PmenuThumb = { bg = colors.fg_muted },
  WildMenu = { fg = colors.fg, bg = colors.selection },
  StatusLine = { fg = colors.fg, bg = colors.bg_panel },
  StatusLineNC = { fg = colors.fg_muted, bg = colors.bg_panel },
  TabLine = { fg = colors.fg_dim, bg = colors.bg_panel },
  TabLineFill = { fg = colors.fg_dim, bg = colors.bg_panel },
  TabLineSel = { fg = colors.fg, bg = colors.bg },

  Comment = { fg = colors.fg_dim },
  Constant = { fg = colors.purple },
  String = { fg = colors.green },
  Character = { fg = colors.green },
  Number = { fg = colors.blue },
  Boolean = { fg = colors.blue },
  Float = { fg = colors.blue },
  Identifier = { fg = colors.fg },
  Function = { fg = colors.yellow },
  Statement = { fg = colors.orange },
  Conditional = { fg = colors.orange },
  Repeat = { fg = colors.orange },
  Label = { fg = colors.orange },
  Operator = { fg = colors.fg },
  Keyword = { fg = colors.orange },
  Exception = { fg = colors.orange },
  PreProc = { fg = colors.annotation },
  Include = { fg = colors.orange },
  Define = { fg = colors.orange },
  Macro = { fg = colors.annotation },
  PreCondit = { fg = colors.annotation },
  Type = { fg = colors.fg },
  StorageClass = { fg = colors.orange },
  Structure = { fg = colors.fg },
  Typedef = { fg = colors.fg },
  Special = { fg = colors.orange },
  SpecialChar = { fg = colors.orange },
  Tag = { fg = colors.orange },
  Delimiter = { fg = colors.fg },
  SpecialComment = { fg = colors.comment_green },
  Debug = { fg = colors.red },
  Underlined = { fg = "#4f86cd", underline = true },
  Ignore = { fg = colors.fg_muted },
  Error = { fg = colors.red_bright },
  Todo = { fg = "#54aae3", bold = true },

  DiagnosticError = { fg = colors.red },
  DiagnosticWarn = { fg = "#e69317" },
  DiagnosticInfo = { fg = colors.blue },
  DiagnosticHint = { fg = colors.fg_dim },
  DiagnosticOk = { fg = colors.green },
  DiagnosticUnderlineError = { sp = colors.red_bright, undercurl = true },
  DiagnosticUnderlineWarn = { sp = "#e69317", undercurl = true },
  DiagnosticUnderlineInfo = { sp = colors.blue, undercurl = true },
  DiagnosticUnderlineHint = { sp = colors.fg_dim, undercurl = true },
  ["@lsp.mod.deprecated"] = { strikethrough = true },
  ["@lsp.type.unresolvedReference"] = { sp = colors.red, undercurl = true },

  DiffAdd = { bg = "#384c38" },
  DiffChange = { bg = "#374752" },
  DiffDelete = { fg = colors.vcs_deleted, bg = colors.bg },
  DiffText = { bg = "#455663" },
  Added = { fg = colors.vcs_added },
  Changed = { fg = colors.vcs_modified },
  Removed = { fg = colors.vcs_deleted },

  GitSignsAdd = { fg = colors.vcs_added, bg = colors.bg_gutter },
  GitSignsChange = { fg = colors.vcs_modified, bg = colors.bg_gutter },
  GitSignsDelete = { fg = colors.vcs_deleted, bg = colors.bg_gutter },

  NeoTreeNormal = { fg = colors.fg, bg = colors.bg_panel },
  NeoTreeNormalNC = { fg = colors.fg, bg = colors.bg_panel },
  NeoTreeEndOfBuffer = { fg = colors.bg_panel, bg = colors.bg_panel },
  NeoTreeWinSeparator = { fg = colors.border, bg = colors.bg_panel },
  NeoTreeCursorLine = { bg = colors.caret_row },
  NeoTreeDirectoryIcon = { fg = colors.blue },
  NeoTreeDirectoryName = { fg = colors.fg },
  NeoTreeFileName = { fg = colors.fg },
  NeoTreeFileNameOpened = { fg = colors.fg_bright },
  NeoTreeRootName = { fg = colors.yellow, bold = true },
  NeoTreeGitAdded = { fg = colors.vcs_added },
  NeoTreeGitModified = { fg = colors.vcs_modified },
  NeoTreeGitDeleted = { fg = colors.vcs_deleted },
  NeoTreeGitUntracked = { fg = colors.vcs_unknown },
  NeoTreeGitIgnored = { fg = "#848504" },
  NeoTreeIndentMarker = { fg = colors.indent },

  TelescopeNormal = { fg = colors.fg, bg = colors.bg_popup },
  TelescopeBorder = { fg = colors.border, bg = colors.bg_popup },
  TelescopeSelection = { fg = colors.fg, bg = colors.selection },
  TelescopeMatching = { fg = colors.yellow },

  WhichKey = { fg = colors.yellow },
  WhichKeyDesc = { fg = colors.fg },
  WhichKeyGroup = { fg = colors.blue },
  WhichKeyBorder = { fg = colors.border, bg = colors.bg_popup },

  CmpItemAbbr = { fg = colors.fg },
  CmpItemAbbrDeprecated = { fg = colors.fg_dim, strikethrough = true },
  CmpItemAbbrMatch = { fg = colors.yellow },
  CmpItemAbbrMatchFuzzy = { fg = colors.yellow },
  CmpItemKind = { fg = colors.blue },
  CmpItemMenu = { fg = colors.fg_dim },

  BlinkCmpMenu = { fg = colors.fg, bg = colors.bg_popup },
  BlinkCmpMenuBorder = { fg = colors.border, bg = colors.bg_popup },
  BlinkCmpMenuSelection = { fg = colors.fg, bg = colors.selection },
  BlinkCmpLabel = { fg = colors.fg },
  BlinkCmpLabelMatch = { fg = colors.yellow },
  BlinkCmpKind = { fg = colors.blue },
  BlinkCmpSource = { fg = colors.fg_dim },
  BlinkCmpDoc = { fg = colors.fg, bg = colors.bg_popup },
  BlinkCmpDocBorder = { fg = colors.border, bg = colors.bg_popup },
  BlinkCmpSignatureHelp = { fg = colors.fg, bg = colors.bg_popup },
  BlinkCmpSignatureHelpBorder = { fg = colors.border, bg = colors.bg_popup },

  TreesitterContext = { bg = colors.bg_panel },
  TreesitterContextLineNumber = { fg = "#a4a3a3", bg = colors.bg_panel },
}

for group, opts in pairs(groups) do
  hl(group, opts)
end

-- Route Tree-sitter and selected LSP semantic groups through the same palette without flattening regular variables.
local links = {
  ["@annotation"] = "PreProc",
  ["@attribute"] = "PreProc",
  ["@boolean"] = "Boolean",
  ["@character"] = "Character",
  ["@comment"] = "Comment",
  ["@comment.documentation"] = "SpecialComment",
  ["@constant"] = "Constant",
  ["@constant.builtin"] = "Constant",
  ["@constant.macro"] = "Macro",
  ["@constructor"] = "Identifier",
  ["@function"] = "Function",
  ["@function.builtin"] = "Function",
  ["@function.call"] = "Identifier",
  ["@function.macro"] = "Macro",
  ["@function.method"] = "Function",
  ["@function.method.call"] = "Identifier",
  ["@keyword"] = "Keyword",
  ["@keyword.conditional"] = "Conditional",
  ["@keyword.exception"] = "Exception",
  ["@keyword.function"] = "Keyword",
  ["@keyword.import"] = "Include",
  ["@keyword.operator"] = "Keyword",
  ["@keyword.repeat"] = "Repeat",
  ["@label"] = "Label",
  ["@module"] = "Identifier",
  ["@number"] = "Number",
  ["@number.float"] = "Float",
  ["@operator"] = "Operator",
  ["@property"] = "Constant",
  ["@punctuation"] = "Delimiter",
  ["@punctuation.bracket"] = "Delimiter",
  ["@punctuation.delimiter"] = "Delimiter",
  ["@string"] = "String",
  ["@string.escape"] = "SpecialChar",
  ["@tag"] = "Tag",
  ["@tag.attribute"] = "Identifier",
  ["@tag.delimiter"] = "Delimiter",
  ["@type"] = "Type",
  ["@type.builtin"] = "Keyword",
  ["@variable"] = "Identifier",
  ["@variable.builtin"] = "Keyword",
  ["@variable.member"] = "Constant",
  ["@variable.parameter"] = "Identifier",
  ["@lsp.type.annotation"] = "PreProc",
  ["@lsp.type.boolean"] = "Boolean",
  ["@lsp.type.builtinType"] = "Type",
  ["@lsp.type.class"] = "Type",
  ["@lsp.type.comment"] = "Comment",
  ["@lsp.type.decorator"] = "PreProc",
  ["@lsp.type.enum"] = "Type",
  ["@lsp.type.enumMember"] = "Constant",
  ["@lsp.type.function"] = "Function",
  ["@lsp.type.interface"] = "Type",
  ["@lsp.type.keyword"] = "Keyword",
  ["@lsp.type.macro"] = "Macro",
  ["@lsp.type.method"] = "Identifier",
  ["@lsp.type.modifier"] = "Keyword",
  ["@lsp.type.namespace"] = "Identifier",
  ["@lsp.type.number"] = "Number",
  ["@lsp.type.operator"] = "Operator",
  ["@lsp.type.property"] = "Constant",
  ["@lsp.type.regexp"] = "String",
  ["@lsp.type.selfKeyword"] = "Keyword",
  ["@lsp.type.selfTypeKeyword"] = "Keyword",
  ["@lsp.type.string"] = "String",
  ["@lsp.type.struct"] = "Type",
  ["@lsp.type.type"] = "Type",
  ["@lsp.type.typeParameter"] = "Type",
  ["@lsp.typemod.function.declaration"] = "Function",
  ["@lsp.typemod.function.definition"] = "Function",
  ["@lsp.typemod.method.declaration"] = "Function",
  ["@lsp.typemod.method.definition"] = "Function",
  ["@lsp.typemod.property.readonly"] = "Constant",
  ["@lsp.typemod.property.static"] = "Constant",
  ["@lsp.typemod.variable.callable"] = "Function",
  ["@lsp.typemod.variable.readonly"] = "Constant",
  ["@lsp.typemod.variable.static"] = "Constant",
}

for group, link in pairs(links) do
  hl(group, { link = link })
end

for _, group in ipairs({
  "@lsp.type.parameter",
  "@lsp.type.parameter.java",
  "@lsp.type.variable",
  "@lsp.type.variable.java",
}) do
  hl(group, {})
end

vim.g.terminal_color_0 = "#000000"
vim.g.terminal_color_1 = "#cf5b56"
vim.g.terminal_color_2 = "#629755"
vim.g.terminal_color_3 = "#ffc66d"
vim.g.terminal_color_4 = "#6897bb"
vim.g.terminal_color_5 = "#9876aa"
vim.g.terminal_color_6 = "#3a8484"
vim.g.terminal_color_7 = "#a9b7c6"
vim.g.terminal_color_8 = "#606366"
vim.g.terminal_color_9 = "#ff0000"
vim.g.terminal_color_10 = "#77b767"
vim.g.terminal_color_11 = "#bbb529"
vim.g.terminal_color_12 = "#4f86cd"
vim.g.terminal_color_13 = "#bfa1f8"
vim.g.terminal_color_14 = "#46a6b2"
vim.g.terminal_color_15 = "#ffffff"
