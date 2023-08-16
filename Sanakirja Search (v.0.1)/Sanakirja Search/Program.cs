using System.Text.RegularExpressions;

DirectoryInfo? dir = Directory.GetParent(System.Reflection.Assembly.GetExecutingAssembly().Location);
List<string> wordBook = File.ReadAllLines($"{dir}/finnish_plain_words.txt").ToList();
//List<string> wordBook = File.ReadAllLines($"{Directory.GetParent(System.Reflection.Assembly.GetExecutingAssembly().Location)}/kotus-sanalista_v1.xml").ToList();

// kotus sanalista setup
/*for (int i = 0; i < wordBook.Count; i++)
{
    // Removes Tags
    wordBook[i] = Regex.Replace(wordBook[i], "<.*?>", "");

    // Removes numbers (taivutus num) (tällä vois erotella sanojen pistearvoja, esim taivutetusta
    // sanasta sais enemmän pisteitä)
    wordBook[i] = new string(wordBook[i].Where(c => !char.IsDigit(c)).ToArray());

    // Remove empty lines
    if (wordBook[i].Length <= 1) { wordBook.RemoveAt(i); i--; }
}*/

// remove "-" ending words
for (int i = 0; i < wordBook.Count; i++)
{
    if (wordBook[i][wordBook[i].Length - 1] == '-')
    {
        wordBook.RemoveAt(i);
        i--;
    }
}

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
        for (int searchAttempts = 2000; searchAttempts > 0; searchAttempts--)
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
            if (foundWords.Count > 3)
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
            if (foundWords.Count > 3)
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
            string path = "D:/Coding Projects/Aistico Godot/AisticoGamePrototypes/Sanapeli v.0.2/data/words.json";
            List<Word>? words = Save.LoadJson(path, typeof(List<Word>)) as List<Word>;
            if (words == null) words = new();
            Word word = new();
            word.Words = foundWords;
            word.Hint = hintList;
            word.Chars = letters;
            words.Add(word);
            Save.SaveJson(words, path);
        }
    }
}

string Input(string write)
{
    Console.Write(write);
    string? read = Console.ReadLine();
    if (read != null) return read;
    else return "";
}