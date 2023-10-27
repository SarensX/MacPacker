// Copyright (c) 2023 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

struct BenchmarkResult: Codable {

    var name: String
    var input: String
    var iterCount: Int
    var avg: Double
    var std: Double

    var id: String {
        return [self.name, self.input, String(self.iterCount)].joined(separator: "<#>")
    }

    func printComparison(with other: BenchmarkResult) {
        let diff = (self.avg / other.avg - 1) * 100
        let comparison = self.compare(with: other)
        if diff < 0 {
            switch comparison {
            case 1:
                print(String(format: "OK  %f%% (p-value > 0.05)", diff))
            case nil:
                print("Cannot compare due to unsupported iteration count.")
            case -1:
                print(String(format: "REG %f%% (p-value < 0.05)", diff))
            case 0:
                print(String(format: "REG %f%% (p-value = 0.05)", diff))
            default:
                swcompExit(.benchmarkUnknownCompResult)
            }
        }
        else if diff > 0 {
            switch comparison {
            case 1:
                print(String(format: "OK  %f%% (p-value > 0.05)", diff))
            case nil:
                print("Cannot compare due to unsupported iteration count.")
            case -1:
                print(String(format: "IMP %f%% (p-value < 0.05)", diff))
            case 0:
                print(String(format: "IMP %f%% (p-value = 0.05)", diff))
            default:
                swcompExit(.benchmarkUnknownCompResult)
            }
        } else {
            print("OK (exact match of averages)")
        }
    }

    private func compare(with other: BenchmarkResult) -> Int? {
        let degreesOfFreedom = Double(self.iterCount + other.iterCount - 2)
        let t1: Double = Double(self.iterCount - 1) * pow(self.std, 2)
        let t2: Double = Double(other.iterCount - 1) * pow(other.std, 2)
        let pooledStd = ((t1 + t2) / degreesOfFreedom).squareRoot()
        let se = pooledStd * (1 / Double(self.iterCount) + 1 / Double(other.iterCount)).squareRoot()
        let tStat = (self.avg - other.avg ) / se
        if degreesOfFreedom == 18 {
            if abs(tStat) > 2.101 {
                // p-value < 0.05
                return -1
            } else if abs(tStat) == 2.101 {
                // p-value = 0.05
                return 0
            } else {
                // p-value > 0.05
                return 1
            }
        } else {
            return nil
        }
    }

}
