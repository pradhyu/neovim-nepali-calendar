local M = {}

M.devanagari_digits = {
  ["0"] = "०",
  ["1"] = "१",
  ["2"] = "२",
  ["3"] = "३",
  ["4"] = "४",
  ["5"] = "५",
  ["6"] = "६",
  ["7"] = "७",
  ["8"] = "८",
  ["9"] = "९",
}

M.months_nepali = {
  "वैशाख",
  "जेठ",
  "असार",
  "साउन",
  "भदौ",
  "असोज",
  "कात्तिक",
  "मंसिर",
  "पुस",
  "माघ",
  "फागुन",
  "चैत",
}

M.months_nepali_formal = {
  "बैशाख",
  "ज्येष्ठ",
  "आषाढ",
  "श्रावण",
  "भाद्र",
  "आश्विन",
  "कार्तिक",
  "मार्गशीर्ष",
  "पौष",
  "माघ",
  "फाल्गुन",
  "चैत्र",
}

M.months_english = {
  "Baishakh",
  "Jestha",
  "Ashadh",
  "Shrawan",
  "Bhadra",
  "Ashwin",
  "Kartik",
  "Mangsir",
  "Poush",
  "Magh",
  "Falgun",
  "Chaitra",
}

M.days_nepali_full = {
  "आइतबार",
  "सोमबार",
  "मंगलबार",
  "बुधबार",
  "बिहीबार",
  "शुक्रबार",
  "शनिबार",
}

M.days_nepali_short = {
  "आइत",
  "सोम",
  "मंगल",
  "बुध",
  "बिही",
  "शुक्र",
  "शनि",
}

M.days_nepali_mini = {
  "आ",
  "सो",
  "मं",
  "बु",
  "बि",
  "शु",
  "श",
}

M.days_english_full = {
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
}

M.days_english_short = {
  "Sun",
  "Mon",
  "Tue",
  "Wed",
  "Thu",
  "Fri",
  "Sat",
}

M.superscript_digits = {
  ["0"] = "⁰",
  ["1"] = "¹",
  ["2"] = "²",
  ["3"] = "³",
  ["4"] = "⁴",
  ["5"] = "⁵",
  ["6"] = "⁶",
  ["7"] = "⁷",
  ["8"] = "⁸",
  ["9"] = "⁹",
}

function M.to_devanagari(val)
  local str = tostring(val)
  local res = ""
  for i = 1, #str do
    local char = str:sub(i, i)
    res = res .. (M.devanagari_digits[char] or char)
  end
  return res
end

function M.to_superscript(val)
  local str = tostring(val)
  local res = ""
  for i = 1, #str do
    local char = str:sub(i, i)
    res = res .. (M.superscript_digits[char] or char)
  end
  return res
end

return M
