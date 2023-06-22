*** Settings ***
Documentation       Template robot main suite.
Library            RPA.Browser.Selenium    auto_close=${False}
Library            RPA.HTTP
Library            RPA.Excel.Files
Library            RPA.Excel.Application
Library            RPA.PDF
Library            RPA.Tables
Library            RPA.Archive
Library    RPA.Salesforce
Library    RPA.Robocorp.WorkItems


*** Tasks ***
Perform Tasks
    Open Website
    Log In
    Order tab
    Download excel
    Fetch data
    Merge PDF
    Convert to ZIP


*** Keywords ***
Open Website
    Open Available Browser    https://robotsparebinindustries.com/#/
    Maximize Browser Window

Log In 
    Input Text    username    maria
    Input Password    password    thoushallnotpass
    Click Button    //*[@id="root"]/div/div/div/div[1]/form/button
    Wait Until Element Is Visible    sales-form

Order tab
    Click Link    Order your robot!
    Wait Until Element Is Visible    //*[@id="root"]/div/div[2]/div/div/div/div
    Click Button    OK
    Wait Until Element Is Visible    //*[@id="root"]


Download excel
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True


Fetch data
    ${orders}=    Read table from CSV    orders.csv
    FOR    ${Order}    IN    @{orders}
        Fill the form    ${Order}
        
    END

Fill the form
    [Arguments]    ${Order}
    Wait Until Element Is Visible    //*[@id="root"]/div
    Select From List By Index    //select[@id='head']    ${Order}[Head]
    Select Radio Button    body    ${Order}[Body]
    Input Text    //div[3]/input    ${order}[Legs]
    Input Text    address    ${Order}[Address]
    Click Button    preview
    Wait Until Element Is Visible    id:robot-preview-image
    Sleep    5 seconds
    Click Button    order
    #Error debugging 
    


    FOR    ${i}    IN RANGE    ${100}
        ${Error}=    Is Element Visible    //div[@class="alert alert-danger"]
        IF    '${Error}'=='True'    Click Button    order
        IF    '${Error}'=='Flase'    BREAK
            
    END
   
    Sleep    5 seconds
    Wait Until Element Is Visible    id:robot-preview-image
    Wait Until Element Is Visible    id:receipt
    #Screenshot + convert to PDF
    Screenshot    id:robot-preview-image    ${CURDIR}${/}ROBOTS${/}${Order}[Order number].png
    ${recepit_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${recepit_html}    ${CURDIR}${/}RECEIPTS${/}${Order}[Order number].pdf
    Open Pdf        ${CURDIR}${/}RECEIPTS${/}${Order}[Order number].pdf
    Close Pdf
    Click Button    order-another
    Click Button    //button[contains(.,'OK')]

Merge PDF
    FOR    ${counter}    IN RANGE    1    20    
        Log    ${counter}
        Open Pdf    ${CURDIR}${/}RECEIPTS${/}${counter}.pdf
        Add Watermark Image To Pdf    ${CURDIR}${/}ROBOTS${/}${counter}.png    ${CURDIR}${/}RECEIPTS${/}${counter}.pdf
        Close Pdf   ${CURDIR}${/}RECEIPTS${/}${counter}.pdf
    END

Convert to ZIP
    Archive Folder With Zip    ${CURDIR}${/}RECEIPTS    ${OUTPUT_DIR}${/}Receipts.Zip

    






    
