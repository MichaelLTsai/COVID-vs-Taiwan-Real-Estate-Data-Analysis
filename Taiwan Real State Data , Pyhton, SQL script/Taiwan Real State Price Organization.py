import os
import pandas as pd
import time
# 歷年資料夾
dirs = [d for d in os.listdir() if d[:4] == 'real']

dfs = []
city_list = "abcdefghijkmnopqtuvwxz"
cities= {"a": "台北市",'b': "臺中市", "c": '基隆市',
         "d": "臺南市", "e": '高雄市', 'f':'新北市',
        'g':'宜蘭縣', 'h':'桃園市','j': "新竹縣",
         'k': '苗栗縣', 'l': '臺中縣', 'm': '南投縣',
        'n': '彰化縣', 'p': '雲林縣', 'q': "嘉義縣",
         'r': "臺南縣", 's': '高雄縣', 't': '屏東縣',
        'u': '花蓮縣', 'v': '臺東縣', 'x': '澎湖縣',
         'y': '台北市', 'w': '金門縣', 'z': '連江縣',
        'i': '嘉義市', 'o': '新竹市'}
for d in dirs:
    for city_code in city_list:
        df = pd.read_csv(
                os.path.join(d,
                f'{city_code}_lvr_land_a.csv'), index_col=False)
        print(d)
        df['Q'] = d[-1]
        df['city'] = cities[city_code]
        dfs.append(df.iloc[1:])
        print("extracting", city_code, "in", d)
df = pd.concat(dfs, sort=True)
file_name = "Taiwan_Real_State_Dataset_v4.csv"
print(df)
df.to_csv(file_name, encoding='utf_8_sig', index=False)

