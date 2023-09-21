using static System.Net.Mime.MediaTypeNames;

string Input(string text)
{
    Console.Write(text + " (text): ");
    string? result = Console.ReadLine();
    if (result != null) return result;
    else return "";
}
int InputInt(string text)
{
    Console.Write(text + " (int): ");
    string? readText = Console.ReadLine();
    if (readText == null) return 0;
    int result = int.Parse(readText);
    return result;
}
bool InputBool(string text)
{
    Console.Write(text + " (t = true | enter key = false): ");
    string? readText = Console.ReadLine();
    if (readText == null) return false;
    if (readText == "t" || readText == "true") return true;
    else return false;
}


string dataPath = "D:\\Coding Projects\\Aistico Godot\\AisticoGamePrototypes\\Putoavat esineet\\data\\itemrows_data.json";
string textureDirectoryPath = "res://sprites/";
string texturePathExtension = ".png";

List<List<Item>> data = new();


bool keepAddingRows = true;
while (keepAddingRows)
{
    Console.WriteLine("! New Row !");
    List<Item> row = new();

    int itemAmount = InputInt("item amount: ");
    Console.WriteLine();
    for (int i = 0; i < itemAmount; i++)
    {
        Console.WriteLine($"Item {i}");
        bool friendly = InputBool("friendly");
        string texture = textureDirectoryPath + Input("texture name without extension") + texturePathExtension;
        int score = InputInt("score");
        Item item = new();
        item.friendly = friendly; item.texture = texture; item.score = score;
        row.Add(item);
        Console.WriteLine();
    }
    data.Add(row);
    Console.WriteLine("\n");
    keepAddingRows = InputBool("continue?");
}

Save.SaveJson(data, dataPath);
Console.WriteLine("\nSaved successfully :)");