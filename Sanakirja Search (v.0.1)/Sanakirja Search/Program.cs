using System.Text.RegularExpressions;

List<string> wordBook = File.ReadAllLines($"{Directory.GetParent(System.Reflection.Assembly.GetExecutingAssembly().Location)}/kotus-sanalista_v1.xml").ToList();

for (int i = 0; i < wordBook.Count; i++)
{
    // Removes Tags
    wordBook[i] = Regex.Replace(wordBook[i], "<.*?>", "");

    // Removes numbers (taivutus num) (tällä vois erotella sanojen pistearvoja, esim taivutetusta
    // sanasta sais enemmän pisteitä)
    wordBook[i] = new string(wordBook[i].Where(c => !char.IsDigit(c)).ToArray());

    // Remove empty lines
    if (wordBook[i].Length <= 1) { wordBook.RemoveAt(i); i--; }
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
}

string Input(string write)
{
    Console.Write(write);
    string? read = Console.ReadLine();
    if (read != null) return read;
    else return "";
}