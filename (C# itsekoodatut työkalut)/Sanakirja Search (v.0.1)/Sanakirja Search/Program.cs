using Newtonsoft.Json;

using System.Diagnostics;
using System.Text.RegularExpressions;

using TextCopy;

DirectoryInfo? dir = Directory.GetParent(System.Reflection.Assembly.GetExecutingAssembly().Location);
List<string> wordBook = File.ReadAllLines($"{dir}/finnish_plain_words.txt").ToList();

// Game Data Paths with different devices
string laptopPath = "D:/Files/AisticoGamePrototypes/Sanapeli v.0.3/data/words.json"; // v.0.3 laptop path!!!
string pcPath = "D:/Coding Projects/Aistico Godot/AisticoGamePrototypes/Sanapeli v.0.4/data/words.json"; // v.0.4 pc path!!!
string gameDataPath = "";
string pathCommand = Input("pc/laptop game data path?: ");
if (pathCommand == "pc") gameDataPath = pcPath;
else if (pathCommand == "laptop") gameDataPath = laptopPath;

// remove "-" ending words
for (int i = 0; i < wordBook.Count; i++)
{
    if (wordBook[i][wordBook[i].Length - 1] == '-')
    {
        wordBook.RemoveAt(i);
        i--;
    }
}

wordBook = RemoveDuplicates(wordBook);

Console.WriteLine("\ncommands: search/hintwords/words/manywords/exit\n");
Console.WriteLine("sanakirja avattu");
Console.WriteLine($"sanarivejä: {wordBook.Count}");
Console.WriteLine();

while (true)
{
    string command = Input("command: ");

    if (command == "search")
    {
        int wordLength = int.Parse(Input("word length: "));
        string hint = Input("hint: ");
        int index = 0;
        int result = 0;
        foreach (string line in wordBook)
        {
            bool found = true;
            if (line.Length != wordLength) { found = false; }
            for (int i = 0; i < line.Length; i++)
            {
                if (i >= hint.Length || hint[i] == ' ') { }
                else if (line[i] != hint[i]) found = false;
            }

            index++;
            if (found == false) continue;

            Console.WriteLine($"[{index}] {line}");
            result++;

        }
        Console.WriteLine("end of search");
        Console.WriteLine($"matches: {result}");
        Console.WriteLine("");
    }
    else if (command == "words")
    {
        int wordLength = int.Parse(Input("word length: "));
        int hintChrsAmount = int.Parse(Input("hint chrs amount: "));
        int usableChrsAmount = int.Parse(Input("usable chrs amount: "));


        List<string> foundWords = new();
        List<char> hintList = new();
        List<char> letters = new();

        Random random = new Random();
        for (int searchAttempts = 10000; searchAttempts > 0; searchAttempts--)
        {
            // Add words that match the wordLength
            foundWords = new();
            foreach (string line in wordBook)
            {
                if (line.Length == wordLength) foundWords.Add(line);
            }

            // Create Hint
            hintList = new();
            for (int i = 0; i < wordLength; i++) hintList.Add(' ');
            for (int i = 0; i < hintChrsAmount; i++)
            {
                char randomChar = (char)('a' + random.Next(26));
                int index = 0;
                while (hintList[index] != ' ') index = random.Next(wordLength - 1);
                hintList[index] = randomChar;
            }

            // Remove words that don't match with the hint
            for (int wordI = 0; wordI < foundWords.Count; wordI++)
            {
                string word = foundWords[wordI];
                for (int i = 0; i < word.Length; i++)
                {
                    if (hintList[i] != ' ' && word[i] != hintList[i])
                    {
                        foundWords.RemoveAt(wordI);
                        wordI--;
                        break;
                    }
                }
            }


            // Select random letters that the words need to have, remove those that don't match them
            letters = new();
            if (foundWords.Count >= 3)
            {
                for (int att = 25; att > 0; att--)
                {
                    List<string> _words = foundWords;
                    List<char> allLetters = new();
                    letters.Clear();

                    // Find allLetters
                    for (int wordI = 0; wordI < _words.Count; wordI++)
                    {
                        string _word = _words[wordI];
                        for (int i = 0; i < _word.Length; i++)
                        {
                            if (hintList[i] == ' ' && !allLetters.Contains(_word[i])) allLetters.Add(_word[i]);
                        }
                    }
                    // Select only few of the all letters
                    for (int i = 0; i < usableChrsAmount; i++)
                    {
                        char c = '?';
                        if (allLetters.Count > 0) c = allLetters[random.Next(allLetters.Count)];
                        letters.Add(c);
                        allLetters.Remove(c);
                    }

                    // Remove words that don't match with the letters
                    for (int wordI = 0; wordI < _words.Count; wordI++)
                    {
                        string word = _words[wordI];
                        for (int i = 0; i < word.Length; i++)
                        {
                            if (hintList[i] == ' ' && !letters.Contains(word[i]))
                            {
                                _words.RemoveAt(wordI);
                                wordI--;
                                break;
                            }
                        }
                    }

                    // Words found
                    if (_words.Count > 3)
                    {
                        att = 0;
                        foundWords = _words;
                    }
                }
            }


            // Print all words that are left
            if (foundWords.Count >= 3)
            {
                searchAttempts = 0;
                for (int i = 0; i < foundWords.Count; i++) Console.WriteLine(foundWords[i]);
                Console.WriteLine("--------------------");
                foreach (char c in hintList) Console.Write(c);
                Console.Write(" <HINT>\n");
                foreach (char c in letters) Console.Write(c);
                Console.Write(" <LETTERS>\n");
                Console.WriteLine("--------------------");
                Console.WriteLine("end\n");
            }
            else if (searchAttempts <= 1) Console.WriteLine("no words found, try again");
        }
        if (Input("add to saved wordlist?: ") == "yes")
        {
            List<Word>? words = Save.LoadJson(gameDataPath, typeof(List<Word>)) as List<Word>;
            if (words == null) words = new();
            Word word = new();
            word.Words = foundWords;
            word.Hint = hintList;
            word.Chars = letters;
            words.Add(word);
            Save.SaveJson(words, gameDataPath);
        }
    }
    else if (command == "manywords")
    {
        int wordLength = int.Parse(Input("word length: "));
        int hintChrsAmount = int.Parse(Input("hint chrs amount: "));
        int usableChrsAmount = int.Parse(Input("usable chrs amount: "));
        int loopIndex = int.Parse(Input("loop times: "));

        for (; loopIndex > 0; loopIndex--)
        {
            List<string> foundWords = new();
            List<char> hintList = new();
            List<char> letters = new();

            Random random = new Random();
            for (int searchAttempts = 10000; searchAttempts > 0; searchAttempts--)
            {
                // Add words that match the wordLength
                foundWords = new();
                foreach (string line in wordBook)
                {
                    if (line.Length == wordLength) foundWords.Add(line);
                }

                // Create Hint
                hintList = new();
                for (int i = 0; i < wordLength; i++) hintList.Add(' ');
                for (int i = 0; i < hintChrsAmount; i++)
                {
                    char randomChar = (char)('a' + random.Next(26));
                    int index = 0;
                    while (hintList[index] != ' ') index = random.Next(wordLength - 1);
                    hintList[index] = randomChar;
                }

                // Remove words that don't match with the hint
                for (int wordI = 0; wordI < foundWords.Count; wordI++)
                {
                    string word = foundWords[wordI];
                    for (int i = 0; i < word.Length; i++)
                    {
                        if (hintList[i] != ' ' && word[i] != hintList[i])
                        {
                            foundWords.RemoveAt(wordI);
                            wordI--;
                            break;
                        }
                    }
                }


                // Select random letters that the words need to have, remove those that don't match them
                letters = new();
                if (foundWords.Count >= 3)
                {
                    for (int att = 25; att > 0; att--)
                    {
                        List<string> _words = foundWords;
                        List<char> allLetters = new();
                        letters.Clear();

                        // Find allLetters
                        for (int wordI = 0; wordI < _words.Count; wordI++)
                        {
                            string _word = _words[wordI];
                            for (int i = 0; i < _word.Length; i++)
                            {
                                if (hintList[i] == ' ' && !allLetters.Contains(_word[i])) allLetters.Add(_word[i]);
                            }
                        }
                        // Select only few of the all letters
                        for (int i = 0; i < usableChrsAmount; i++)
                        {
                            char c = '?';
                            if (allLetters.Count > 0) c = allLetters[random.Next(allLetters.Count)];
                            letters.Add(c);
                            allLetters.Remove(c);
                        }

                        // Remove words that don't match with the letters
                        for (int wordI = 0; wordI < _words.Count; wordI++)
                        {
                            string word = _words[wordI];
                            for (int i = 0; i < word.Length; i++)
                            {
                                if (hintList[i] == ' ' && !letters.Contains(word[i]))
                                {
                                    _words.RemoveAt(wordI);
                                    wordI--;
                                    break;
                                }
                            }
                        }

                        // Words found
                        if (_words.Count > 3)
                        {
                            att = 0;
                            foundWords = _words;
                        }
                    }
                }


                // Print all words that are left
                if (foundWords.Count >= 3)
                {
                    searchAttempts = 0;
                    Console.WriteLine("\nwords found");
                    Console.WriteLine("--------------------");
                    for (int i = 0; i < foundWords.Count; i++) Console.WriteLine(foundWords[i]);
                    Console.WriteLine("--------------------");
                    foreach (char c in hintList) Console.Write(c);
                    Console.Write(" <HINT>\n");
                    foreach (char c in letters) Console.Write(c);
                    Console.Write(" <LETTERS>\n");
                    Console.WriteLine("--------------------");
                    Console.WriteLine("end\n");
                }
                else if (searchAttempts <= 1) Console.WriteLine("no words found, try again");
            }
            if (Input("add to saved wordlist?: ") == "yes")
            {
                List<Word>? words = Save.LoadJson(gameDataPath, typeof(List<Word>)) as List<Word>;
                if (words == null) words = new();
                Word word = new();
                word.Words = foundWords;
                word.Hint = hintList;
                word.Chars = letters;
                words.Add(word);
                Save.SaveJson(words, gameDataPath);
            }
        }
    }
    else if (command == "hintwords")
    {
        int minWordLength = int.Parse(Input("min word length: "));
        int maxWordLength = int.Parse(Input("max word length: "));
        
        List<string> wordMatches = SearchByLength(wordBook, minWordLength, maxWordLength);

        Console.WriteLine("\nSelect words (yes = press enter) (no = type n) (stop = type stop)");
        Console.WriteLine("-----------------------------------------------------------------");

        // Setup Selecting
        Random random = new Random();
        List<string> selectedWords = new();
        string selectCommand = "";

        // Select words
        while (selectCommand != "stop")
        {
            string word = wordMatches[random.Next(wordMatches.Count - 1)];
            Console.Write(word + " ");
            selectCommand = Input("/");
            if (selectCommand != "n" && selectCommand != "stop") selectedWords.Add(word);
        }

        // Set ChatGPT command to be copied to clipboard
        string chatGPTcommand = "anna sanoille erikseen lyhyt ja ytimekäs määritelmä, jolla voisi pelissä arvata sen sanan. " +
            "Tee se JSONissa, ja käytä listan muuttujissa termejä: word ja definition" +
            "Muista pitää määritelmät muutamissa sanoissa.\n" +
            "Käytä formaattia:\n[\r\n  {\r\n    \"word\": \"jahti\",\r\n    \"definition\": \"Metsästysretki tai suuri vene.\"\r\n  },\r\n  {\r\n    \"word\": \"kävely\",\r\n    \"definition\": \"Hitaasti etenevä liikkumistapa, yleensä jalkaisin.\"\r\n  }\n";
        foreach (string word in selectedWords) chatGPTcommand += "\n" + word;
        ClipboardService.SetText(chatGPTcommand);

        // Wait for JSON
        Console.WriteLine("command copied. paste it in chat gpt");
        Console.WriteLine("waiting for copied json from chat gpt...");
        bool clipboardIsJson = false;
        while (clipboardIsJson == false)
        {
            clipboardIsJson = Save.IsJson(ClipboardService.GetText());
        }
        Console.WriteLine("json in clipboard\n");

        // Save JSON
        string? clip = ClipboardService.GetText();
        if (clip == null) return;
        List<HintWord>? wordsData = Save.LoadJson(gameDataPath, typeof(List<HintWord>)) as List<HintWord>;
        List<HintWord>? copiedJson = Save.JsonToObject(clip, typeof(List<HintWord>)) as List<HintWord>;
        if (wordsData == null) wordsData = new();
        if (copiedJson == null) return;

        foreach (HintWord w in copiedJson) wordsData.Add(w); // Add all new words to wordsData
        Save.SaveJson(wordsData, gameDataPath);

        Console.WriteLine("words saved successfully\n");
    }
    else if (command == "sort")
    {
        List<HintWord>? wordsData = Save.LoadJson(gameDataPath, typeof(List<HintWord>)) as List<HintWord>;
        if (wordsData == null) continue;
        wordsData.Sort((a, b) => string.Compare(a.word, b.word, StringComparison.OrdinalIgnoreCase));
        for (int i = 0; i < wordsData.Count; i++) Console.WriteLine(wordsData[i].word);
        if (Input("save (yes/no): ") == "yes") Save.SaveJson(wordsData, gameDataPath);
    }
    else if (command == "exit") Environment.Exit(0);
}

string Input(string write)
{
    Console.Write(write);
    string? read = Console.ReadLine();
    if (read != null) return read;
    else return "";
}

List<string> RemoveDuplicates(List<string> _words)
{
    List<string> result = new();
    string lastWord = "";
    foreach (string word in _words)
    {
        if (word != lastWord) result.Add(word);
        lastWord = word;
    }
    return result;
}

List<string> SearchByLength(List<string> _words, int _min,  int _max)
{
    List<string> _result = new();
    foreach (string _word in _words)
    {
        if (_word.Length >= _min && _word.Length <= _max) _result.Add(_word);
    }
    return _result;
}