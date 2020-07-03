/**
 * @file
 * Implements Commodity Channel Index Arrays (CCI Arrays) indicator.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_CCI.mqh>

#property copyright ""
#property link ""
#property version "1.00"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_color1 Blue
#property indicator_type1 DRAW_ARROW
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_color2 Red
#property indicator_type2 DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2

double dUpCCIBuffer[];
double dDownCCIBuffer[];

input int CCI_Period = 21;
input ENUM_APPLIED_PRICE CCI_Applied_Price = PRICE_CLOSE;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit() {
  IndicatorSetString(INDICATOR_SHORTNAME, "CCI_Arrows(" + IntegerToString(CCI_Period) + ")");

  SetIndexBuffer(0, dUpCCIBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, dDownCCIBuffer, INDICATOR_DATA);

  PlotIndexSetInteger(0, PLOT_ARROW, 233);
  PlotIndexSetInteger(1, PLOT_ARROW, 234);

  PlotIndexSetString(0, PLOT_LABEL, "CCI Buy");
  PlotIndexSetString(1, PLOT_LABEL, "CCI Sell");
}

//+------------------------------------------------------------------+
//| Custom CCI Arrows                                                |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[],
                const double &High[], const double &Low[], const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
  ArraySetAsSeries(High, true);
  ArraySetAsSeries(Low, true);

  double CCIBuffer[];
  // Or make the dynamic call?
  int myCCI = ::iCCI(NULL, 0, CCI_Period, CCI_Applied_Price);
  CopyBuffer(myCCI, 0, 0, rates_total, CCIBuffer);

  for (int i = rates_total; i > 1; i--) {
    dUpCCIBuffer[rates_total - i + 1] = 0;
    dDownCCIBuffer[rates_total - i + 1] = 0;

    double myCCInow = CCIBuffer[rates_total - i + 1];
    double myCCI2 = CCIBuffer[rates_total - i];

    if (myCCInow >= 0) {
      if ((myCCInow > 0) && (myCCI2 < 0)) {
        dUpCCIBuffer[rates_total - i + 1] = Low[i] - 2 * _Point;
      }
    }

    if (myCCInow < 0) {
      if ((myCCInow < 0) && (myCCI2 > 0)) {
        dDownCCIBuffer[rates_total - i + 1] = High[i] + 2 * _Point;
      }
    }
  }

  return (rates_total);
}
