class HaryanviConverter {
  /// Converts standard Hindi text to Haryanvi dialect using rule-based replacement.
  static String convertToHaryanvi(String hindiText) {
    String text = hindiText;

    // 1. Basic Pronouns & Verbs
    text = text.replaceAll(RegExp(r'\bमैं\b'), 'मन्नै'); // Main -> Manne
    text = text.replaceAll(RegExp(r'\bहम\b'), 'हम्'); // Hum -> Ham
    text = text.replaceAll(RegExp(r'\bहै\b'), 'स'); // Hai -> Se/Sa
    text = text.replaceAll(RegExp(r'\bहैं\b'), 'सैं'); // Hain -> Sain
    text = text.replaceAll(RegExp(r'\bथा\b'), 'था'); // Tha (Same)
    text = text.replaceAll(RegExp(r'\bथी\b'), 'थी'); // Thi (Same)
    
    // 2. Common Haryanvi Vocabulary
    text = text.replaceAll(RegExp(r'\bलड़का\b'), 'छोरा'); // Ladka -> Chhora
    text = text.replaceAll(RegExp(r'\bलड़की\b'), 'छोरी'); // Ladki -> Chhori
    text = text.replaceAll(RegExp(r'\bवहाँ\b'), 'ओड़े'); // Wahan -> Ode
    text = text.replaceAll(RegExp(r'\bयहाँ\b'), 'उरै'); // Yahan -> Ure
    text = text.replaceAll(RegExp(r'\bकहाँ\b'), 'कड़े'); // Kahan -> Kade
    text = text.replaceAll(RegExp(r'\bक्या\b'), 'के'); // Kya -> Ke
    text = text.replaceAll(RegExp(r'\bक्यों\b'), 'क्यूँ'); // Kyun -> Kyu
    text = text.replaceAll(RegExp(r'\bनहीं\b'), 'ना'); // Nahi -> Na
    text = text.replaceAll(RegExp(r'\bअच्छा\b'), 'सुथरा'); // Accha -> Suthra
    text = text.replaceAll(RegExp(r'\bपागल\b'), 'बावला'); // Pagal -> Bawla
    
    // 3. Farming Specific
    text = text.replaceAll(RegExp(r'\bखेत\b'), 'खेत'); // Khet (Same)
    text = text.replaceAll(RegExp(r'\bपानी\b'), 'पाणी'); // Pani -> Paani
    text = text.replaceAll(RegExp(r'\bमिट्टी\b'), 'माटी'); // Mitti -> Maati
    text = text.replaceAll(RegExp(r'\bपौधा\b'), 'बूटा'); // Paudha -> Boota
    text = text.replaceAll(RegExp(r'\bबीमारी\b'), 'रोग'); // Bimari -> Rog
    text = text.replaceAll(RegExp(r'\bइलाज\b'), 'टोटका'); // Ilaaj -> Totka/Upchar
    text = text.replaceAll(RegExp(r'\bदवा\b'), 'दवाई'); // Dawa -> Dawai
    text = text.replaceAll(RegExp(r'\bछिड़काव\b'), 'छिड़काव'); // Chidkav (Same)

    // 4. Grammar Tweaks (Suffixes)
    // Walas: Khetwala -> Khetala
    text = text.replaceAll('वाला', 'आला'); 
    text = text.replaceAll('वाली', 'आली');
    
    // Ko -> Ne (Mujhko -> Manne, Isko -> Isne)
    text = text.replaceAll(RegExp(r'\bको\b'), 'नै');
    
    // Ka/Ki -> Ka/Ki (Often similar but tone changes, keeping simple for text)

    return text;
  }
}
