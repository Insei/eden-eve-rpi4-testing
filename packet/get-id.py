import json,sys;
try:
    json_obj=json.load(sys.stdin);
    print(json_obj["id"]);
except Exception:
    print("00000000-0000-0000-0000-000000000000");
