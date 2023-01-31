using Pkg
Pkg.add("CSVFiles")
using DataTables
using CSV
using ExcelFiles
using DataFrames
using CSVFiles
using XLSX
using Plots

pwd()
cd("D:\\OneDrive - knu.ac.kr\\GitHub\\coding\\학석사\\ASF\\data")

readdir()
dt = XLSX.openxlsx("ASF.xlsx")
data = dt["Sheet 1"]
data = data[:]
data = DataFrame(data, :auto)
describe(data)

dropmissing!(data)
data = data[:, [:x3, :x9, :x10]]
data

typeof(data.x10)
for i in 1:length(data.x10)
    data.x10 = convert.(Float64, data.x10)
end