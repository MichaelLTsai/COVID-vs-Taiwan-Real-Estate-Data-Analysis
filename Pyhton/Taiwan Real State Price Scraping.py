import requests
import os
import zipfile
import time


def real_estate_crawler(year, season):
    if year > 1000:
        year -= 1911

    # download real estate zip file
    res = requests.get("https://plvr.land.moi.gov.tw//DownloadSeason?season="
                       + str(year) + "S" + str(season) +
                       "&type=zip&fileName=lvr_landcsv.zip")

    # save content to file
    fname = str(year)+str(season)+'.zip'
    open(fname, 'wb').write(res.content)

    # make additional folder for files to extract
    folder = 'real_estate' + str(year) + str(season)
    if not os.path.isdir(folder):
        os.mkdir(folder)

    # extract files to the folder
    with zipfile.ZipFile(fname, 'r') as zip_ref:
        zip_ref.extractall(folder)

    time.sleep(10)


def main():
    for year in range(107, 112):
        for season in range(1, 5):
            print(year, season)
            real_estate_crawler(year, season)


if __name__ == "__main__":
    main()