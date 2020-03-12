interface JsonApiResource {
  data: {
    id?: string
    type: string
    attributes: any
    relationships?: any
  }
}

export default JsonApiResource
