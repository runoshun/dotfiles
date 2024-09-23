return function()
  local key = vim.fn.getcharstr()
  local byte = string.byte(key)
  local key_name = vim.fn.keytrans(key)

  print("Raw input: " .. vim.inspect(key))
  print("Byte value: " .. byte)
  print("Key name: " .. key_name)

  -- 修飾キーの検出
  local mods = ""
  if vim.fn.match(key, "\\C^\\(<C-\\)") > -1 then mods = mods .. "Ctrl+" end
  if vim.fn.match(key, "\\C^\\(<M-\\|<A-\\)") > -1 then mods = mods .. "Alt+" end
  if vim.fn.match(key, "\\C^\\(<S-\\)") > -1 then mods = mods .. "Shift+" end

  if mods ~= "" then
    print("Modifiers: " .. mods:sub(1, -2))   -- 最後の "+" を削除
  end
end
