*** Settings ***
Documentation     Orders from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt and images as a PDF file 
...               Add the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library         RPA.Browser
Library         RPA.Tables
Library         RPA.Robocloud.Secrets
Library         RPA.PDF
Library         RPA.Excel.Files
Library         Dialogs
Library         RPA.HTTP
Library         RPA.core.notebook
Library         RPA.Archive
Library         RPA.FileSystem

*** Keywords **
Open order website
    ${web}=    Get Secret    webdata
    Open Available Browser  ${web}[order_url]  


** Keywords **
Oders
    ${csv}=  Get Value From User   dowload the oders.csv file url  https://robotsparebinindustries.com/orders.csv
    Download  ${csv}  orders.csv
    ${oder_data}=    Read Table From Csv    orders.csv    dialect=excel  header=True
    FOR     ${row}  IN  @{oder_data}
        Log     ${row}
    END
    [Return]    ${oder_data}


** Keywords ***
Close dialogs
    Wait Until Page Contains Element    //button[contains(text(),'OK')]
    Click Button    //button[contains(text(),'OK')]

*** Keywords ***
Complete the oder form
    [Arguments]    ${row}
    ${head}=        Convert To Integer    ${row}[Head]
    ${body}=        Convert To Integer    ${row}[Body]
    ${legs}=        Convert To Integer    ${row}[Legs]
    ${address}=     Convert To String    ${row}[Address]
    Select From List By Value       //select[@name="head"]   ${head}
    Click Element                   //input[@value="${Body}"]
    Input Text                      //input[@placeholder="Enter the part number for the legs"]    ${legs}
    Input Text                      //input[@placeholder="Shipping address"]    ${address}


*** Keywords ***
Click preview
    Click Button  //button[@id="preview"]
    Wait Until Page Contains Element  //div[@id="robot-preview-image"]

** Keywords **
Click submit
    Click Button    //button[@id="order"]
    FOR  ${i}  IN RANGE  ${100}
        ${alert}=  Is Element Visible  //div[@class="alert alert-danger"]  
        Run Keyword If  '${alert}'=='True'  Click Button  //button[@id="order"] 
        Exit For Loop If  '${alert}'=='False'       
    END


*** Keywords ****
Complete Pdf receipts 
    [Arguments]    ${row}
    Sleep  2 seconds   
    ${pdf_receipt}=    Get Element Attribute    //div[@id='receipt']    outerHTML
    Html To Pdf    ${pdf_receipt}    ${CURDIR}${/}output${/}receipt${/}${row}[Order number].pdf
    Screenshot     //div[@id="robot-preview-image"]   ${CURDIR}${/}output${/}screenshot${/}${row}[Order number].png
    Add Watermark Image To Pdf    ${CURDIR}${/}output${/}screenshot${/}${row}[Order number].png    ${CURDIR}${/}output${/}receipt${/}${row}[Order number].pdf   ${CURDIR}${/}output${/}receipt${/}${row}[Order number].pdf


*** Keywords ***
Go to new order 
    Click Button    //button[@id='order-another']

***Keywords***
Creates ZIP receipts and images
    Archive Folder With Zip    ${CURDIR}${/}output${/}receipt    receipt.zip

*** Tasks ***
Order from RobotSpareBin Industries Inc
    Open order website
    ${orders}=    Oders
    FOR    ${row}    IN    @{orders}
        Close dialogs
        Complete the oder form    ${row}
        Click preview
        Click submit
        Complete Pdf receipts       ${row} 
        Go to new order
    END
    Creates ZIP receipts and images

