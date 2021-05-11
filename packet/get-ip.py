import json,sys;
try:
    json_obj=json.load(sys.stdin);
    print(json_obj["ip_addresses"][0]["address"]);
except Exception:
    print("0.0.0.0");
