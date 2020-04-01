interface JsonApiResourceData {
  id?: string
  type: string
  attributes: any
  relationships?: any
}

interface JsonApiResource {
  data: JsonApiResourceData
}

export { JsonApiResource, JsonApiResourceData }
