import pandas as pd
import numpy as np


def main():
    this_year = 111
    df = pd.read_csv("Taiwan_Real_State_Dataset.csv")
    df['year'] = df['交易年月日'].apply(lambda x: int(str(x)[:-4]) + 1911 if len(str(x)) > 4 else 0)
    df['month'] = df['交易年月日'].apply(lambda x: int(str(x)[-4:-2]) if len(str(x)) > 4 else 0)
    df["建築完成年月"] = df["建築完成年月"].astype(object)
    df["建築完成年月"] = pd.to_numeric(df["建築完成年月"], errors='coerce', downcast='integer')
    df["建築完成年月"] = df["建築完成年月"].apply(lambda x: -1 if np.isnan(x) else int(x))
    df["build_year"] = df["建築完成年月"].apply(lambda x: 111 - int(str(x)[:-4]) if len(str(x)) > 4 else x)
    df['單價元坪'] = df['單價元平方公尺'] * 3.30579
    df['總坪數'] = df['建物移轉總面積平方公尺'] * 0.3025
    df['建物型態2'] = df['建物型態'].str.split('(').str[0]
    # df = df[df['備註'].isnull())]
    df = df[df["建物移轉總面積平方公尺"] != 0]
    print(df.dtypes)
    print(df.head())
    print(df[["year", "month", "build_year", "建築完成年月", "交易年月日"]])
    print(df[['建物移轉總面積平方公尺', '總坪數', '單價元平方公尺', '單價元坪', '建物型態2']])


if __name__ == "__main__":
    main()