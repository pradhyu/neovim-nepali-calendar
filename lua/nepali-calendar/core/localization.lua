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

M.tithis_english = {
  ["प्रतिपदा"] = "Pratipada (Day 1)",
  ["द्दितीया"] = "Dwitiya (Day 2)",
  ["द्वितीया"] = "Dwitiya (Day 2)",
  ["तृतीया"] = "Tritiya (Day 3)",
  ["चतुर्थी"] = "Chaturthi (Day 4)",
  ["पञ्चमी"] = "Panchami (Day 5)",
  ["षष्ठी"] = "Shasthi (Day 6)",
  ["सप्तमी"] = "Saptami (Day 7)",
  ["अष्टमी"] = "Ashtami (Day 8)",
  ["नवमी"] = "Navami (Day 9)",
  ["दशमी"] = "Dashami (Day 10)",
  ["एकादशी"] = "Ekadashi (Day 11)",
  ["द्वादशी"] = "Dwadashi (Day 12)",
  ["त्रयोदशी"] = "Trayodashi (Day 13)",
  ["चतुर्दशी"] = "Chaturdashi (Day 14)",
  ["पुर्णिमा"] = "Purnima (Full Moon)",
  ["पूर्णिमा"] = "Purnima (Full Moon)",
  ["औशी"] = "Aushi / Amavasya (New Moon)",
  ["औँसी"] = "Aushi / Amavasya (New Moon)",
}

M.festival_translations = {
  ["नव बर्ष"] = "Nepali New Year",
  ["नववर्ष"] = "Nepali New Year",
  ["नयाँ वर्ष"] = "Nepali New Year",
  ["लोकतन्त्र दिवस"] = "Democracy Day (Loktantra Diwas)",
  ["प्रजातन्त्र दिवस"] = "National Democracy Day",
  ["अन्त्राष्ट्रिय श्रमिक दिवस"] = "International Workers' Day (May Day)",
  ["अन्तर्राष्ट्रिय महिला दिवस"] = "International Women's Day",
  ["नारी दिवस"] = "Women's Day",
  ["बुद्ध जयन्ती"] = "Buddha Jayanti / Ubhauli",
  ["उभौली पर्व"] = "Ubhauli Festival",
  ["उधौली पर्व"] = "Udhauli Festival",
  ["गणतन्त्र दिवस"] = "Republic Day (Ganatantra Diwas)",
  ["संविधान दिवस"] = "Constitution Day (Sanbidhan Diwas)",
  ["राष्ट्रिय धान दिवस"] = "National Paddy Day (Ropain Diwas)",
  ["साउन संक्रान्ती"] = "Saune Sankranti",
  ["साउने संक्रान्ति"] = "Saune Sankranti",
  ["खिर खाने दिन"] = "Kheer Khane Din",
  ["खीर खाने दिन"] = "Kheer Khane Din",
  ["ऋषितर्पणी, रक्षाबन्धन"] = "Janai Purnima / Raksha Bandhan",
  ["रक्षाबन्धन"] = "Raksha Bandhan",
  ["गाईजात्रा"] = "Gai Jatra (Saparu)",
  ["श्रीकृष्णजन्माष्टमी"] = "Shree Krishna Janmashtami",
  ["गौरा पर्व"] = "Gaura Parva",
  ["इन्द्रजात्रा"] = "Indra Jatra (Yenya)",
  ["घटस्थापना"] = "Ghatasthapana (Dashain Begins)",
  ["फूलपाती"] = "Phulpati (Dashain Saptami)",
  ["महाअष्टमी"] = "Maha Ashtami / Kalratri",
  ["महानवमी"] = "Maha Navami",
  ["विजयादशमी"] = "Vijaya Dashami (Dashain Tika)",
  ["विजया दशमी"] = "Vijaya Dashami (Dashain Tika)",
  ["बिजया दशमी"] = "Vijaya Dashami (Dashain Tika)",
  ["कोजाग्रत पूर्णिमा"] = "Kojagrat Purnima (Dashain Ends)",
  ["काग तिहार"] = "Kag Tihar (Crow Day)",
  ["कुकुर तिहार"] = "Kukur Tihar (Dog Day)",
  ["लक्ष्मी पुजा"] = "Laxmi Puja / Deepawali",
  ["लक्ष्मी पूजा"] = "Laxmi Puja / Deepawali",
  ["दिपावली"] = "Deepawali",
  ["गोवर्धन पूजा"] = "Govardhan Puja / Mha Puja",
  ["भाइटीका"] = "Bhai Tika (Kija Puja)",
  ["भाइ टीका"] = "Bhai Tika (Kija Puja)",
  ["छठ पर्व"] = "Chhath Parva",
  ["माघे संक्रान्ति"] = "Maghe Sankranti",
  ["सोनाम ल्होसार"] = "Sonam Lhosar",
  ["ग्याल्पो ल्होसार"] = "Gyalpo Lhosar",
  ["तमु ल्होसार"] = "Tamu Lhosar",
  ["महाशिवरात्री"] = "Maha Shivaratri",
  ["शिवरात्री"] = "Shivaratri",
  ["फागु पूर्णिमा"] = "Holi (Fagu Purnima)",
  ["होली"] = "Holi Festival",
  ["घोडे जात्रा"] = "Ghode Jatra",
  ["घोडेजात्रा"] = "Ghode Jatra",
  ["चैते दशैं"] = "Chaite Dashain",
  ["श्री राम नवमी"] = "Ram Navami",
  ["हरितालिका व्रत"] = "Haritalika Teej",
  ["तीज"] = "Teej Festival",
  ["दरखाने दिन"] = "Darkhane Din (Teej Eve)",
  ["ऋषिपञ्चमी"] = "Rishi Panchami",
  ["क्रिसमस डे"] = "Christmas Day",
  ["शहीद दिवस"] = "Martyrs' Day",
}

function M.translate_tithi(tithi_np)
  if not tithi_np or tithi_np == "" then
    return ""
  end
  return M.tithis_english[tithi_np] or tithi_np
end

function M.translate_festival(fest_np)
  if not fest_np or fest_np == "" then
    return ""
  end

  for np_pattern, en_trans in pairs(M.festival_translations) do
    if fest_np:find(np_pattern, 1, true) then
      return string.format("%s (%s)", en_trans, fest_np)
    end
  end

  return fest_np
end

return M
