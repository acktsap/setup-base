local M = {}

local function normalize(path)
  return vim.fn.fnamemodify(vim.fn.expand(path), ":p")
end

local function dirname(path)
  return vim.fn.fnamemodify(path, ":p:h")
end

local function basename(path)
  return vim.fn.fnamemodify(path, ":t:r")
end

local function package_for(dir)
  local normalized = normalize(dir):gsub("\\", "/"):gsub("/$", "")
  local package_path = normalized:match("/src/[^/]+/java/(.+)$")
  if package_path then
    return package_path:gsub("/", ".")
  end
  if normalized:match("/src/[^/]+/java$") then
    return ""
  end
end

function M.prepare_path(path)
  if vim.fn.fnamemodify(path, ":e") ~= "" then
    return path
  end
  if package_for(dirname(path)) ~= nil then
    return path .. ".java"
  end
  return path
end

function M.initial_content(path)
  if vim.fn.fnamemodify(path, ":e") ~= "java" then
    return
  end

  local class_name = basename(path)
  if not class_name:match("^[%a_$][%w_$]*$") then
    return {}
  end

  local package_name = package_for(dirname(path))
  if package_name == nil then
    return {}
  end

  local lines = {}
  if package_name ~= "" then
    vim.list_extend(lines, { "package " .. package_name .. ";", "" })
  end
  vim.list_extend(lines, {
    "public class " .. class_name .. " {",
    "}",
  })
  return lines
end

return M
