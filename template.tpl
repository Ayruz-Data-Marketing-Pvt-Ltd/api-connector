___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "API Connector",
  "categories": [
    "UTILITY",
    "DATA_WAREHOUSING"
  ],
  "brand": {
    "id": "github.com_ayruz-data-marketing",
    "displayName": "Ayruz-data-marketing"
  },
  "description": "Send POST request, to API endpoint, with JSON body and desired headers.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "url",
    "displayName": "Endpoint URL",
    "simpleValueType": true,
    "valueHint": "https://",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "CHECKBOX",
    "name": "sendAllEventData",
    "checkboxText": "Send all event data",
    "simpleValueType": true,
    "help": "Add all event data from data layer to request body"
  },
  {
    "type": "GROUP",
    "name": "requestData",
    "displayName": "Request Data",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "data",
        "displayName": "",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Property",
            "name": "key",
            "type": "TEXT"
          },
          {
            "defaultValue": "",
            "displayName": "Value",
            "name": "value",
            "type": "TEXT"
          }
        ],
        "newRowButtonText": "Add Value"
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "requestHeaders",
    "displayName": "Request Headers",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "simpleTable1",
        "displayName": "",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Key",
            "name": "key",
            "type": "TEXT"
          },
          {
            "defaultValue": "",
            "displayName": "Value",
            "name": "value",
            "type": "TEXT"
          }
        ],
        "newRowButtonText": "Add Header"
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "additionalOption",
    "displayName": "Additional Options",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "SELECT",
        "name": "requestMethod",
        "displayName": "Request Method",
        "macrosInSelect": false,
        "selectItems": [
          {
            "value": "POST",
            "displayValue": "POST"
          },
          {
            "value": "PUT",
            "displayValue": "PUT"
          }
        ],
        "simpleValueType": true,
        "defaultValue": "POST"
      },
      {
        "type": "TEXT",
        "name": "requestTimeout",
        "displayName": "Request Timeout",
        "simpleValueType": true,
        "defaultValue": 3000,
        "valueValidators": [
          {
            "type": "NON_NEGATIVE_NUMBER"
          }
        ]
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

const sendHttpRequest = require('sendHttpRequest');
const getAllEventData = require('getAllEventData');
const makeInteger = require('makeInteger');
const makeTableMap = require('makeTableMap');
const JSON = require('JSON');
const getRequestHeader = require('getRequestHeader');
const log = require('logToConsole');
const getContainerVersion = require('getContainerVersion');
const containerVersion = getContainerVersion();
const isDebug = containerVersion.debugMode;
const traceId = getRequestHeader('trace-id');

const postHeaders = {'Content-Type': 'application/json'};
let postBodyData = {};

if (data.sendAllEventData) {
    postBodyData = getAllEventData();
}

if (data.headers) {
    for (let key in data.headers) {
        postHeaders[data.headers[key].key] = data.headers[key].value;
    }
}

if (data.data) {
    let postBodyCustomData = makeTableMap(data.data, 'key', 'value');

    for (let key in postBodyCustomData) {
        postBodyData[key] = postBodyCustomData[key];
    }
}

const postBody = JSON.stringify(postBodyData);
let requestOptions = {headers: postHeaders, method: data.requestMethod};

if (data.requestTimeout) {
    requestOptions.timeout = makeInteger(data.requestTimeout);
}

if (isDebug) {
    log(JSON.stringify({
        'Name': 'JSON Request',
        'Type': 'Request',
        'TraceId': traceId,
        'RequestMethod': data.requestMethod,
        'RequestUrl': data.url,
        'RequestBody': postBodyData,
    }));
}

sendHttpRequest(data.url, (statusCode, headers, body) => {
    if (isDebug) {
        log(JSON.stringify({
            'Name': 'JSON Request',
            'Type': 'Response',
            'TraceId': traceId,
            'ResponseStatusCode': statusCode,
            'ResponseHeaders': headers,
            'ResponseBody': body,
        }));
    }

    if (statusCode >= 200 && statusCode < 300) {
        data.gtmOnSuccess();
    } else {
        data.gtmOnFailure();
    }
}, requestOptions, postBody);


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_request",
        "versionId": "1"
      },
      "param": [
        {
          "key": "headerWhitelist",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "trace-id"
                  }
                ]
              }
            ]
          }
        },
        {
          "key": "headersAllowed",
          "value": {
            "type": 8,
            "boolean": true
          }
        },
        {
          "key": "requestAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "headerAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "queryParameterAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_container_data",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  }
]


