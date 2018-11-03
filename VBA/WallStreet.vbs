Attribute VB_Name = "Module1"
Sub ProcessStockData()
    Dim s As Integer
    'loop through each sheet
    For s = 1 To Sheets.Count
        ExtractYearlyStockData (s)
        MsgBox ("Done Processing sheet " + Str(s))
    Next s
    Sheets(1).Activate

End Sub

Sub cleanslate()
    'delete existing results
    For i = 8 To 20
        Columns(8).EntireColumn.Delete
    Next i
    'MsgBox ("cleanslate")

End Sub

Sub ExtractYearlyStockData(snum As Integer)

    Dim i, lastrow, totalvol, resrow, rescol, maxrescol, maxvol, c, mrow As Long
    Dim yoprice, ycprice, chg, chgperc, maxinc, maxdec As Double
    Dim curticker, newticker, mvticker, miticker, mdticker As String

    'initialise result row
    maxvol = 0
    maxinc = 0
    maxdec = 0
    mvticker = ""
    miticker = ""
    mdticker = ""

    'activate current sheet
    Sheets(snum).Activate
    cleanslate
    rescol = 1 + Cells(1, Columns.Count).End(xlToLeft).Column
    resrow = 2
    maxrescol = rescol + 5

    Cells(1, rescol + 1).Value = "Ticker"
    Cells(1, rescol + 2).Value = "Yearly Change"
    Cells(1, rescol + 3).Value = "Percent Change"
    Cells(1, rescol + 4).Value = "Total Stock Volume"


    'get the lastrow in this sheet
    lastrow = Cells(Rows.Count, 1).End(xlUp).Row

    'initialize with row 2 : ticker, volume and opening price
    curticker = Cells(2, 1).Value
    vol = Cells(2, 7).Value
    totalvol = vol
    yoprice = Cells(2, 3).Value

    'start scanning from row 3
    For Row = 3 To lastrow
        'read next row : ticker and volume
        newticker = Cells(Row, 1).Value
        vol = Cells(Row, 7).Value

        If newticker = curticker Then
            'if same ticker, add totalvol
            totalvol = totalvol + vol
            'need to keep scanning until yoprice reaches a non-zero value i.e the stock is listed
            If yoprice = 0 Then
                yoprice = Cells(Row, 3).Value
            End If
        Else
            'get closing price for previous row/ticker
            ycprice = Cells(Row - 1, 6).Value

            'calc yearly change and set colorindex value
            chg = ycprice - yoprice
            If chg = 0 Then
                c = 4
                chgperc = 0
            ElseIf chg > 0 Then
                c = 4
                'calc change percentage
                chgperc = chg / yoprice
            Else
                c = 3
                'calc change percentage
                chgperc = chg / yoprice
            End If

            'identify maxvol, maxinc and maxdec
            If maxvol < totalvol Then
                maxvol = totalvol
                mvticker = curticker
            End If
            If maxinc < chgperc Then
                maxinc = chgperc
                miticker = curticker
            End If
            If maxdec > chgperc Then
                maxdec = chgperc
                mdticker = curticker
            End If

            'record results in the sheet
            Cells(resrow, rescol + 1).Value = curticker
            Cells(resrow, rescol + 2).Value = chg
            Cells(resrow, rescol + 2).Interior.ColorIndex = c
            Cells(resrow, rescol + 3).Value = chgperc
            Cells(resrow, rescol + 3).NumberFormat = "0.00%"
            Cells(resrow, rescol + 4).Value = totalvol

            'increment result row
            resrow = resrow + 1
            curticker = newticker
            totalvol = vol

            'record new opening price
            yoprice = Cells(Row, 3).Value
        End If

    Next Row
    'do all the good stuff one last time
    ycprice = Cells(Row - 1, 6).Value
    chg = ycprice - yoprice
    If chg > 0 Then
        c = 4
    Else
        c = 3
    End If

    'record results in the sheet
    Cells(resrow, rescol + 1).Value = curticker
    Cells(resrow, rescol + 2).Value = chg
    Cells(resrow, rescol + 2).Interior.ColorIndex = c
    Cells(resrow, rescol + 3).Value = (chg / yoprice)
    Cells(resrow, rescol + 3).NumberFormat = "0.00%"
    Cells(resrow, rescol + 4).Value = totalvol

    mrow = 1
    Cells(mrow, maxrescol + 2).Value = "Ticker"
    Cells(mrow, maxrescol + 3).Value = "Value"
    mrow = 2
    'record greatest increase
    Cells(mrow, maxrescol + 1).Value = "Greatest % Increase"
    Cells(mrow, maxrescol + 2).Value = miticker
    Cells(mrow, maxrescol + 3).Value = maxinc
    Cells(mrow, maxrescol + 3).NumberFormat = "0.00%"
    mrow = 3
    'record greatest decrease
    Cells(mrow, maxrescol + 1).Value = "Greatest % Decrease"
    Cells(mrow, maxrescol + 2).Value = mdticker
    Cells(mrow, maxrescol + 3).Value = maxdec
    Cells(mrow, maxrescol + 3).NumberFormat = "0.00%"
    mrow = 4
    'record greatest volume
    Cells(mrow, maxrescol + 1).Value = "Greatest Total Volume"
    Cells(mrow, maxrescol + 2).Value = mvticker
    Cells(mrow, maxrescol + 3).Value = maxvol
    'MsgBox ("Final results")

End Sub

