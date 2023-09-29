using static System.Net.Mime.MediaTypeNames;

#region Input Functions
string Input(string text)
{
    Console.Write(text + ": ");
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
#endregion

Console.WriteLine("Create itemrows_data for putoavat esineet game. Keep a backup of the old data, because this overwrites the used data\n\n");


List<string> imageSources = new()
{
    "<a href=\"https://www.freepik.com/free-vector/sticker-set-mixed-daily-objects_27286523.htm#query=everyday%20objects&position=16&from_view=keyword&track=ais\">Image by brgfx</a> on Freepik",
    "<a href=\"https://www.freepik.com/free-vector/set-transportation-vehicle_4453029.htm#query=everyday%20objects%20car&position=4&from_view=search&track=ais\">Image by brgfx</a> on Freepik",
    "<a href=\"https://www.freepik.com/free-vector/faceless-children-walking-white-background_1169220.htm#query=walking%20cartoonish&position=8&from_view=search&track=ais\">Image by brgfx</a> on Freepik",
    "<a href=\"https://www.freepik.com/free-vector/cute-bicycles-different-colors-set-illustrations-eco-city-transport-kids-adults_20827606.htm#query=cycle%20cartoonish&position=1&from_view=search&track=ais\">Image by pch.vector</a> on Freepik",
    "<a href=\"https://www.freepik.com/free-vector/illustration-motorcycle-red-color_6026996.htm#query=motorcycle%20cartoonish&position=21&from_view=search&track=ais\">Image by brgfx</a> on Freepik",
    "<a href=\"https://www.freepik.com/free-vector/set-different-foods_4546020.htm#query=food%20cartoonish&position=15&from_view=search&track=ais\">Image by brgfx</a> on Freepik"
};

string PCdataPath = "D:\\Coding Projects\\Aistico Godot\\AisticoGamePrototypes\\Putoavat esineet\\data\\itemrows_data.json";
string LaptopDataPath = "D:\\Files\\Git\\AisticoGamePrototypes\\Putoavat esineet\\data\\itemrows_data.json";
string dataPath = "";
string textureDirectoryPath = "res://sprites/items/";
string texturePathExtension = ".png";

List<List<Item>> data = new();

// Select dataPath
string pathCommand = Input("select dataPath (pc/laptop/custom)");
if (pathCommand == "pc") dataPath = PCdataPath;
else if (pathCommand == "laptop") dataPath = LaptopDataPath;
else if (pathCommand == "custom") dataPath = Input("path");
Console.WriteLine("");


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
        int score = InputInt("score");
        string texture = textureDirectoryPath + Input("texture name without extension") + texturePathExtension;
        string source = imageSources[InputInt("source id") - 1];
        Item item = new();
        item.friendly = friendly; item.texture = texture; item.score = score; item.source = source;
        row.Add(item);
        Console.WriteLine();
    }
    data.Add(row);
    Console.WriteLine("\n");
    keepAddingRows = InputBool("continue?");
}

Save.SaveJson(data, dataPath);
Console.WriteLine("\nSaved successfully :)");