"use strict"
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
var adjustment_1 = __importDefault(require("../../src/models/adjustment"))
describe("Adjustment", function () {
  test("toJsonApi", function () {
    var adj = new adjustment_1.default({
      id: "5",
      routeId: "Red",
      source: "gtfs_creator",
      sourceLabel: "AlewifeHarvard",
    })
    expect(adj.toJsonApi()).toEqual({
      data: {
        id: "5",
        type: "adjustment",
        attributes: {
          route_id: "Red",
          source_label: "AlewifeHarvard",
          source: "gtfs_creator",
        },
      },
    })
  })
  test("fromJsonObject success", function () {
    expect(
      adjustment_1.default.fromJsonObject({
        type: "adjustment",
        id: "1",
        attributes: {
          source: "gtfs_creator",
          route_id: "Red",
          source_label: "AlewifeHarvard",
        },
      })
    ).toEqual(
      new adjustment_1.default({
        id: "1",
        routeId: "Red",
        source: "gtfs_creator",
        sourceLabel: "AlewifeHarvard",
      })
    )
    expect(
      adjustment_1.default.fromJsonObject({
        type: "adjustment",
        id: "1",
        attributes: {
          source: "arrow",
          route_id: "Red",
          source_label: "AlewifeHarvard",
        },
      })
    ).toEqual(
      new adjustment_1.default({
        id: "1",
        routeId: "Red",
        source: "arrow",
        sourceLabel: "AlewifeHarvard",
      })
    )
  })
  test("fromJsonObject error wrong format", function () {
    expect(adjustment_1.default.fromJsonObject({})).toEqual("error")
  })
  test("fromJsonObject error not an object", function () {
    expect(adjustment_1.default.fromJsonObject(5)).toEqual("error")
  })
})
