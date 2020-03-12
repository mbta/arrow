import JsonApiResource from "../jsonApiResource"

class Exception {
  id?: number
  excludedDate?: Date

  constructor({ id, excludedDate }: { id?: number; excludedDate?: Date }) {
    this.id = id
    this.excludedDate = excludedDate
  }

  serialize(): JsonApiResource {
    return {
      data: {
        type: "exception",
        ...(this.id && { id: this.id.toString() }),
        attributes: {
          ...(this.excludedDate && {
            excluded_date: this.excludedDate.toISOString().slice(0, 10),
          }),
        },
      },
    }
  }
}

export default Exception
