using System;

public class Save
{
    public static void SaveJson(object _file, string _path)
    {
        string _contents = Newtonsoft.Json.JsonConvert.SerializeObject(_file, Newtonsoft.Json.Formatting.Indented);
        File.WriteAllText(_path, _contents);
    }

    public static object LoadJson(string _path, Type _type)
    {
        try
        {
            string _contents = File.ReadAllText(_path);
            object? _obj = Newtonsoft.Json.JsonConvert.DeserializeObject(_contents, _type);
            if (_obj != null) return _obj;
        }
        catch { }

        object o = new();
        return o;
    }
}

[System.Serializable]
public class Word
{
    public List<string> Words = new();
    public List<char> Hint = new();
    public List<char> Chars = new();
}