using Plots

x = rand(100)
y = randn(100)

plot(x,y, seriestype = :scatter)
using Pkg
using CSV
import Pkg
Pkg.add("DataTables")
using DataFrames, XLSX
cd("d:/OneDrive - knu.ac.kr/GitHub/coding/")


data = XLSX.readxlsx("부산대 금융공동연구/df_case_clean_0508.xlsx") 
covid = data["Sheet 1"]
covid
using DataTables
data["Sheet 1!A1:G832"]


# 줄리아에서 데이터프레임에 새 행 추가하는 방법
using DataFrames
Unit1 = DataFrame(
    member = ["A", "B", "C", "D", "E"],
    age = [20, 30, 40, 50, 60],
    height = [170, 180, 190, 200, 210]
)

Unit2 = DataFrame(
    member = ["F", "G", "H", "I", "J"],
    age = [20, 30, 40, 50, 60],
    height = [170, 180, 190, 200, 210]
)

# vcat : python에서의 concat과 같은 기능
summit = vcat(Unit1, Unit2)
summit

push!(summit, ["K", 20, 170])


# 줄리아에서 데이터프레임에 새 열 추가하는 방법
summit[!, :"score"] = [100, 90, 80, 70, 60, 50, 40, 30, 20, 10, 0]
# !는 :와 비슷한 의미로 쓰이는 듯, 그리고 :를 자주 쓰는 듯

# 데이터프레임 정렬하는 방법
sort(summit, :age, rev = false)