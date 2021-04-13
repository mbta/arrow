"use strict"
Object.defineProperty(exports, "__esModule", { value: true })
var api_1 = require("../src/api")
var mockFetch = function (status, json) {
  window.fetch = function () {
    return Promise.resolve({
      json: function () {
        return json
      },
      status: status,
    })
  }
}
var mockFetchFailure = function () {
  window.fetch = function () {
    return Promise.reject("network failure")
  }
}
describe("apiSend", function () {
  test("parses successful create", function (done) {
    mockFetch(201, { data: "success" })
    var successParse = jest.fn(function () {
      return "success"
    })
    api_1
      .apiSend({
        url: "/",
        method: "POST",
        json: "{}",
        successParser: successParse,
        errorParser: function () {
          return "error"
        },
      })
      .then(function (parsed) {
        expect(successParse).toHaveBeenCalledWith({ data: "success" })
        expect(parsed).toEqual({ ok: "success" })
        done()
      })
  })
  test("parses successful update", function (done) {
    mockFetch(200, { data: "success" })
    var successParse = jest.fn(function () {
      return "success"
    })
    api_1
      .apiSend({
        url: "/",
        method: "PATCH",
        json: "{}",
        successParser: successParse,
        errorParser: function () {
          return "error"
        },
      })
      .then(function (parsed) {
        expect(successParse).toHaveBeenCalledWith({ data: "success" })
        expect(parsed).toEqual({ ok: "success" })
        done()
      })
  })
  test("handles 204 response", function (done) {
    window.fetch = function () {
      return Promise.resolve({
        status: 204,
      })
    }
    var successParse = jest.fn(function () {
      return "success"
    })
    api_1
      .apiSend({
        url: "/",
        method: "DELETE",
        json: "",
        successParser: successParse,
        errorParser: function () {
          return "error"
        },
      })
      .then(function (parsed) {
        expect(successParse).toHaveBeenCalledWith(null)
        expect(parsed).toEqual({ ok: "success" })
        done()
      })
  })
  test("parses error response", function (done) {
    mockFetch(400, { data: "error" })
    var errorParse = jest.fn(function () {
      return "error"
    })
    api_1
      .apiSend({
        url: "/",
        method: "POST",
        json: "{}",
        successParser: function () {
          return "success"
        },
        errorParser: errorParse,
      })
      .then(function (parsed) {
        expect(errorParse).toHaveBeenCalledWith({ data: "error" })
        expect(parsed).toEqual({ error: "error" })
        done()
      })
  })
  test("promise reject if there are errors", function (done) {
    mockFetchFailure()
    api_1
      .apiSend({
        url: "/",
        method: "POST",
        json: "{}",
        successParser: function () {
          return "success"
        },
        errorParser: function () {
          return "error"
        },
      })
      .catch(function (err) {
        expect(err).toEqual("network failure")
        done()
      })
  })
  test("promise reject if unexpected error code", function (done) {
    mockFetch(500, { data: "error" })
    api_1
      .apiSend({
        url: "/",
        method: "POST",
        json: "{}",
        successParser: function () {
          return "success"
        },
        errorParser: function () {
          return "error"
        },
      })
      .catch(function (err) {
        expect(err).toEqual("fetch/parse error")
        done()
      })
  })
})
describe("apiGet", function () {
  var reloadSpy
  beforeEach(function () {
    // Dirty: setting window.location as writable so we can spy on reload function.
    // Doing this once here to avoid it in all other tests.
    Object.defineProperty(window, "location", {
      writable: true,
      value: { reload: jest.fn() },
    })
    reloadSpy = jest.spyOn(window.location, "reload")
    reloadSpy.mockImplementation(function () {
      return {}
    })
  })
  afterEach(function () {
    reloadSpy.mockRestore()
  })
  test("returns parsed data", function (done) {
    mockFetch(200, { data: "raw" })
    var parse = jest.fn(function () {
      return "parsed"
    })
    api_1
      .apiGet({
        url: "/",
        parser: parse,
      })
      .then(function (parsed) {
        expect(parse).toHaveBeenCalledWith({ data: "raw" })
        expect(parsed).toEqual("parsed")
        done()
      })
  })
  test("reloads the page if the response status is a redirect (3xx)", function (done) {
    mockFetch(302, { data: null })
    api_1
      .apiGet({
        url: "/",
        parser: function () {
          return null
        },
      })
      .catch(function () {
        expect(reloadSpy).toHaveBeenCalled()
        done()
      })
  })
  test("reloads the page if the response status is forbidden (403)", function (done) {
    mockFetch(403, { data: null })
    api_1
      .apiGet({
        url: "/",
        parser: function () {
          return null
        },
      })
      .catch(function () {
        expect(reloadSpy).toHaveBeenCalled()
        done()
      })
  })
  test("returns a default for any other response", function (done) {
    mockFetch(500, { data: null })
    api_1
      .apiGet({
        url: "/",
        parser: function () {
          return null
        },
        defaultResult: "default",
      })
      .then(function (result) {
        expect(result).toEqual("default")
        done()
      })
  })
  test("throws an error for any other response status if there's no default", function (done) {
    mockFetch(500, { data: null })
    api_1
      .apiGet({
        url: "/",
        parser: function () {
          return null
        },
      })
      .then(function () {
        done("fetchRoutes did not throw an error")
      })
      .catch(function (error) {
        expect(error).toBeDefined()
        done()
      })
  })
})
