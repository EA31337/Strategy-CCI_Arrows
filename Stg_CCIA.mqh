//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements CCI strategy based on the Commodity Channel Index indicator.
 */

// Includes.
#include "Indi_CCIA.mqh"
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT string __CCIA_Parameters__ = "-- CCI strategy params --";  // >>> CCI <<<
INPUT int CCIA_Shift = 1;                                        // Shift (0 for default)
INPUT int CCIA_Period = 58;                                      // Period
INPUT ENUM_APPLIED_PRICE CCIA_Applied_Price = 2;                 // Applied Price
INPUT int CCIA_SignalOpenMethod = 0;                             // Signal open method (-63-63)
INPUT double CCIA_SignalOpenLevel = 18;                          // Signal open level (-49-49)
INPUT int CCIA_SignalOpenFilterMethod = 0;                       // Signal open filter method
INPUT int CCIA_SignalOpenBoostMethod = 0;                        // Signal open boost method
INPUT int CCIA_SignalCloseMethod = 0;                            // Signal close method (-63-63)
INPUT double CCIA_SignalCloseLevel = 18;                         // Signal close level (-49-49)
INPUT int CCIA_PriceLimitMethod = 0;                             // Price limit method (0-6)
INPUT double CCIA_PriceLimitLevel = 0;                           // Price limit level
double CCIA_MaxSpread = 6.0;                                     // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_CCIA_Params : StgParams {
  unsigned int CCIA_Period;
  ENUM_APPLIED_PRICE CCIA_Applied_Price;
  int CCIA_Shift;
  int CCIA_SignalOpenMethod;
  double CCIA_SignalOpenLevel;
  int CCIA_SignalOpenFilterMethod;
  int CCIA_SignalOpenBoostMethod;
  int CCIA_SignalCloseMethod;
  double CCIA_SignalCloseLevel;
  int CCIA_PriceLimitMethod;
  double CCIA_PriceLimitLevel;
  double CCIA_MaxSpread;

  // Constructor: Set default param values.
  Stg_CCIA_Params()
      : CCIA_Period(::CCIA_Period),
        CCIA_Applied_Price(::CCIA_Applied_Price),
        CCIA_Shift(::CCIA_Shift),
        CCIA_SignalOpenMethod(::CCIA_SignalOpenMethod),
        CCIA_SignalOpenLevel(::CCIA_SignalOpenLevel),
        CCIA_SignalOpenFilterMethod(::CCIA_SignalOpenFilterMethod),
        CCIA_SignalOpenBoostMethod(::CCIA_SignalOpenBoostMethod),
        CCIA_SignalCloseMethod(::CCIA_SignalCloseMethod),
        CCIA_SignalCloseLevel(::CCIA_SignalCloseLevel),
        CCIA_PriceLimitMethod(::CCIA_PriceLimitMethod),
        CCIA_PriceLimitLevel(::CCIA_PriceLimitLevel),
        CCIA_MaxSpread(::CCIA_MaxSpread) {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_CCIA : public Strategy {
 public:
  Stg_CCIA(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_CCIA *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_CCIA_Params _params;
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Stg_CCIA_Params>(_params, _tf, stg_cci_m1, stg_cci_m5, stg_cci_m15, stg_cci_m30, stg_cci_h1,
                                    stg_cci_h4, stg_cci_h4);
    }
    // Initialize strategy parameters.
    CCIParams cci_params(_params.CCIA_Period, _params.CCIA_Applied_Price);
    cci_params.SetTf(_tf);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_CCI(cci_params), NULL, NULL);
    sparams.logger.SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.CCIA_SignalOpenMethod, _params.CCIA_SignalOpenLevel, _params.CCIA_SignalOpenFilterMethod,
                       _params.CCIA_SignalOpenBoostMethod, _params.CCIA_SignalCloseMethod, _params.CCIA_SignalCloseLevel);
    sparams.SetPriceLimits(_params.CCIA_PriceLimitMethod, _params.CCIA_PriceLimitLevel);
    sparams.SetMaxSpread(_params.CCIA_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_CCIA(sparams, "CCI");
    return _strat;
  }

  /**
   * Check if CCI indicator is on buy or sell.
   *
   * @param
   *   _cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   _method (int) - signal method to use by using bitwise AND operation
   *   _level (double) - signal level to consider the signal
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    Chart *_chart = Chart();
    Indi_CCI *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid() && _indi[PREV].IsValid() && _indi[PPREV].IsValid();
    bool _result = _is_valid;
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    double level = _level * Chart().GetPipSize();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result = _indi[CURR].value[0] > 0 && _indi[CURR].value[0] < -_level;
        if (_method != 0) {
          if (METHOD(_method, 0)) _result &= _indi[CURR].value[0] > _indi[PREV].value[0];
          if (METHOD(_method, 1)) _result &= _indi[PREV].value[0] > _indi[PPREV].value[0];
          if (METHOD(_method, 2)) _result &= _indi[PREV].value[0] < -_level;
          if (METHOD(_method, 3)) _result &= _indi[PPREV].value[0] < -_level;
          if (METHOD(_method, 4)) _result &= _indi[CURR].value[0] - _indi[PREV].value[0] > _indi[PREV].value[0] - _indi[PPREV].value[0];
          if (METHOD(_method, 5)) _result &= _indi[PPREV].value[0] > 0;
        }
        break;
      case ORDER_TYPE_SELL:
        _result = _indi[CURR].value[0] > 0 && _indi[CURR].value[0] > _level;
        if (_method != 0) {
          if (METHOD(_method, 0)) _result &= _indi[CURR].value[0] < _indi[PREV].value[0];
          if (METHOD(_method, 1)) _result &= _indi[PREV].value[0] < _indi[PPREV].value[0];
          if (METHOD(_method, 2)) _result &= _indi[PREV].value[0] > _level;
          if (METHOD(_method, 3)) _result &= _indi[PPREV].value[0] > _level;
          if (METHOD(_method, 4)) _result &= _indi[PREV].value[0] - _indi[CURR].value[0] > _indi[PPREV].value[0] - _indi[PREV].value[0];
          if (METHOD(_method, 5)) _result &= _indi[PPREV].value[0] < 0;
        }
        break;
    }
    return _result;
  }

  /**
   * Check strategy's opening signal additional filter.
   */
  bool SignalOpenFilter(ENUM_ORDER_TYPE _cmd, int _method = 0) {
    bool _result = true;
    if (_method != 0) {
      // if (METHOD(_method, 0)) _result &= Trade().IsTrend(_cmd);
      // if (METHOD(_method, 1)) _result &= Trade().IsPivot(_cmd);
      // if (METHOD(_method, 2)) _result &= Trade().IsPeakHours(_cmd);
      // if (METHOD(_method, 3)) _result &= Trade().IsRoundNumber(_cmd);
      // if (METHOD(_method, 4)) _result &= Trade().IsHedging(_cmd);
      // if (METHOD(_method, 5)) _result &= Trade().IsPeakBar(_cmd);
    }
    return _result;
  }

  /**
   * Gets strategy's lot size boost (when enabled).
   */
  double SignalOpenBoost(ENUM_ORDER_TYPE _cmd, int _method = 0) {
    bool _result = 1.0;
    if (_method != 0) {
      // if (METHOD(_method, 0)) if (Trade().IsTrend(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 1)) if (Trade().IsPivot(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 2)) if (Trade().IsPeakHours(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 3)) if (Trade().IsRoundNumber(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 4)) if (Trade().IsHedging(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 5)) if (Trade().IsPeakBar(_cmd)) _result *= 1.1;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    return SignalOpen(Order::NegateOrderType(_cmd), _method, _level);
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  double PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, double _level = 0.0) {
    Indi_CCI *_indi = Data();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 0: {
        int _bar_count = (int) _level * (int) _indi.GetPeriod();
        _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count)) : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count));
        break;
      }
    }
    return _result;
  }
};
