using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

using System;

public class Save
{
    public static void SaveJson(object _file, string _path)
    {
        string _contents = Newtonsoft.Json.JsonConvert.SerializeObject(_file, Newtonsoft.Json.Formatting.Indented);
        File.WriteAllText(_path, _contents);
    }

    public static void SavePureJson(string _json, string _path)
    {
        File.WriteAllText(_path, _json);
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

    public static object JsonToObject(string _json, Type _type)
    {
        try
        {
            object? _obj = Newtonsoft.Json.JsonConvert.DeserializeObject(_json, _type);
            if (_obj != null) return _obj;
        }
        catch { }

        object o = new();
        return o;
    }

    public static bool IsJson(string? _input)
    {
        if (_input == null) return false;
        try
        {
            JToken.Parse(_input);
            return true;
        }
        catch
        {
            return false;
        }
    }
}

[System.Serializable]
public class Item
{
    public bool friendly = false;
    public int score = 0;
    public string texture = "";
    public string source = "";
}