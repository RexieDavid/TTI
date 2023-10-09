/**********************************************************************
 * @author                  Francis Nasalita
 * @date                    2020-09-24
 *
 * @description             RCTI Invoice Upload Ready Storage Specific Attributes DTO
 */
public class SpRctiInvoiceUploadReadySsaDtoAws {

    public SpRctiInvoiceUploadReadySsaDtoAws() {
        //
    }

    public class Aws {
        public String accountId { get; set; } 
        public String invoiceNumber { get; set; } 
        public String caseNumber { get; set; } 

        public Aws() {
            //
        }

        public Aws(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'accountId') {
                            accountId = parser.getText();
                        } else if (text == 'invoiceNumber') {
                            invoiceNumber = parser.getText();
                        } else if (text == 'caseNumber') {
                            caseNumber = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public Aws aws { get; set; } 

    public SpRctiInvoiceUploadReadySsaDtoAws(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'aws') {
                        aws = new Aws(parser);
                    } else {
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public static SpRctiInvoiceUploadReadySsaDtoAws parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new SpRctiInvoiceUploadReadySsaDtoAws(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
}