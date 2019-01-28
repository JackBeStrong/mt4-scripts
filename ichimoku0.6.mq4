//+------------------------------------------------------------------+
//|                                                     ichimoku.mq4 |
//|                                                          Jack An |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Jack An"
#property link      ""
#property version   "1.00"
#property strict

// version 0.1 
// * introduced multiple currencies
// * incroduced different time frame: 1, 4, 24 hours

// version 0.2
// * changed data source to default mt4 demo data
// * revert calculation to built in ichimoku

// version 0.3
// * introduced price(bid) in alert message
// * added logger file when msg is sent

// version 0.4 23/01/18
// * turn off 1h alerts

// version 0.5 25/01/18
// * remove EURJPY, GBPJPY, corss currency

// version 0.6 14/01/19
// * added half hour line

// version 0.7 27/01/19
//当一个30分钟、1小时、4小时bar close的时候
//对于 AUDUSD GBPUSD EURUSD NZDUSD XAUUSD USDJPY USDCAD USDCHF 这几个币种
//如果high（刚close完的这跟BAR的最高价） > 4条线中的任意一条线，检测low是否小于这条线，如果是，发出提示 
//(eg.AUDUSD 30分钟走完一根bar，检测high是否大于4根线，如果高于Conversion line 和 Base line, 分别检测 low是不是小于Conversion line和 Base line，如果low 小于coversion line 但是不小于base line， 任然提示）
//如果low（刚close完的这跟BAR的最低价） < 4条线中的任意一条线，检测high是否大于这条线，如果是，发出提示


// set constant-------------------------------------------------------
int reportPeriod = 1800; // report gap
string currenies[7] = {"AUDUSD","USDJPY",
   "EURUSD","GBPUSD","USDCAD","NZDUSD","XAUAUD"}; // currencies
// -------------------------------------------------------------------

// set global variables ----------------------------------------------
double prices[];

// variables for 1h
double kijun_sens[];
double senkouSpanAs[];
double senkouSpanBs[];
bool aboveKijun_sens[];
bool aboveSenkouSpanAs[];
bool aboveSenkouSpanBs[];
int counters[];
// variables for 4h
double kijun_sens_4h[];
double senkouSpanAs_4h[];
double senkouSpanBs_4h[];
bool aboveKijun_sens_4h[];
bool aboveSenkouSpanAs_4h[];
bool aboveSenkouSpanBs_4h[];
int counters_4h[];
// variables for 24h
double kijun_sens_24h[];
double senkouSpanAs_24h[];
double senkouSpanBs_24h[];
bool aboveKijun_sens_24h[];
bool aboveSenkouSpanAs_24h[];
bool aboveSenkouSpanBs_24h[];
int counters_24h[];

// variables for half h
double kijun_sens_halfh[];
double senkouSpanAs_halfh[];
double senkouSpanBs_halfh[];
bool aboveKijun_sens_halfh[];
bool aboveSenkouSpanAs_halfh[];
bool aboveSenkouSpanBs_halfh[];
int counters_halfh[];

// -------------------------------------------------------------------


int OnInit(){
   int noOfCurrencies = ArraySize(currenies);
   
   // initialize all arrays depending on how many currencies
   ArrayResize(prices,noOfCurrencies);
   
   // 1h
   ArrayResize(kijun_sens,noOfCurrencies);
   ArrayResize(senkouSpanAs,noOfCurrencies);
   ArrayResize(senkouSpanBs,noOfCurrencies);
   ArrayResize(aboveKijun_sens,noOfCurrencies);
   ArrayResize(aboveSenkouSpanAs,noOfCurrencies);
   ArrayResize(aboveSenkouSpanBs,noOfCurrencies);
   ArrayResize(counters,noOfCurrencies);
   // 4h
   ArrayResize(kijun_sens_4h,noOfCurrencies);
   ArrayResize(senkouSpanAs_4h,noOfCurrencies);
   ArrayResize(senkouSpanBs_4h,noOfCurrencies);
   ArrayResize(aboveKijun_sens_4h,noOfCurrencies);
   ArrayResize(aboveSenkouSpanAs_4h,noOfCurrencies);
   ArrayResize(aboveSenkouSpanBs_4h,noOfCurrencies);
   ArrayResize(counters_4h,noOfCurrencies);
   // 24h
   ArrayResize(kijun_sens_24h,noOfCurrencies);
   ArrayResize(senkouSpanAs_24h,noOfCurrencies);
   ArrayResize(senkouSpanBs_24h,noOfCurrencies);
   ArrayResize(aboveKijun_sens_24h,noOfCurrencies);
   ArrayResize(aboveSenkouSpanAs_24h,noOfCurrencies);
   ArrayResize(aboveSenkouSpanBs_24h,noOfCurrencies);
   ArrayResize(counters_24h,noOfCurrencies);
   // halfh
   ArrayResize(kijun_sens_halfh,noOfCurrencies);
   ArrayResize(senkouSpanAs_halfh,noOfCurrencies);
   ArrayResize(senkouSpanBs_halfh,noOfCurrencies);
   ArrayResize(aboveKijun_sens_halfh,noOfCurrencies);
   ArrayResize(aboveSenkouSpanAs_halfh,noOfCurrencies);
   ArrayResize(aboveSenkouSpanBs_halfh,noOfCurrencies);
   ArrayResize(counters_halfh,noOfCurrencies);
   
   for(int i = 0; i < ArraySize(currenies); i++){
      prices[i] = NormalizeDouble(MarketInfo(currenies[i],MODE_BID),5);
      
      // set variables for 1h
      kijun_sens[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_H1, 9, 26, 52, MODE_KIJUNSEN,0),5);
      senkouSpanAs[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_H1, 9, 26, 52, MODE_SENKOUSPANA,0),5);
      senkouSpanBs[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_H1, 9, 26, 52, MODE_SENKOUSPANB,0),5);
      aboveKijun_sens[i] = checkLine(prices[i], kijun_sens[i]);
      aboveSenkouSpanAs[i] = checkLine(prices[i], senkouSpanAs[i]);
      aboveSenkouSpanBs[i] = checkLine(prices[i], senkouSpanBs[i]);
      counters[i] = reportPeriod;
      
      // set variables for 4h
      kijun_sens_4h[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_H4, 9, 26, 52, MODE_KIJUNSEN,0),5);
      senkouSpanAs_4h[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_H4, 9, 26, 52, MODE_SENKOUSPANA,0),5);
      senkouSpanBs_4h[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_H4, 9, 26, 52, MODE_SENKOUSPANB,0),5);
      aboveKijun_sens_4h[i] = checkLine(prices[i], kijun_sens_4h[i]);
      aboveSenkouSpanAs_4h[i] = checkLine(prices[i], senkouSpanAs_4h[i]);
      aboveSenkouSpanBs_4h[i] = checkLine(prices[i], senkouSpanBs_4h[i]);
      counters_4h[i] = reportPeriod;
      
      // set variables for 24h
      kijun_sens_24h[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_D1, 9, 26, 52, MODE_KIJUNSEN,0),5);
      senkouSpanAs_24h[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_D1, 9, 26, 52, MODE_SENKOUSPANA,0),5);
      senkouSpanBs_24h[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_D1, 9, 26, 52, MODE_SENKOUSPANB,0),5);
      aboveKijun_sens_24h[i] = checkLine(prices[i], kijun_sens_24h[i]);
      aboveSenkouSpanAs_24h[i] = checkLine(prices[i], senkouSpanAs_24h[i]);
      aboveSenkouSpanBs_24h[i] = checkLine(prices[i], senkouSpanBs_24h[i]);
      counters_24h[i] = reportPeriod;
      
      // set variables for halfh
      kijun_sens_halfh[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_M30, 9, 26, 52, MODE_KIJUNSEN,0),5);
      senkouSpanAs_halfh[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_M30, 9, 26, 52, MODE_SENKOUSPANA,0),5);
      senkouSpanBs_halfh[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_M30, 9, 26, 52, MODE_SENKOUSPANB,0),5);
      aboveKijun_sens_halfh[i] = checkLine(prices[i], kijun_sens_halfh[i]);
      aboveSenkouSpanAs_halfh[i] = checkLine(prices[i], senkouSpanAs_halfh[i]);
      aboveSenkouSpanBs_halfh[i] = checkLine(prices[i], senkouSpanBs_halfh[i]);
      counters_halfh[i] = reportPeriod;
      
      
      
      
      Print(currenies[i], ": ", prices[i]);
      
   }
   //sendAlert("The script starts, discard the msg","The script starts, discard the msg");
   Alert("Started");
   
//   sendAlert("INITIATED","DISCARD");
   
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
}

void OnTick(){
   int noOfCurrencies = ArraySize(currenies);
   for(int i = 0; i < noOfCurrencies; i++){
      prices[i] = NormalizeDouble(MarketInfo(currenies[i],MODE_BID),5);
      // 1h
      kijun_sens[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_H1, 9, 26, 52, MODE_KIJUNSEN,0),5);
      senkouSpanAs[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_H1, 9, 26, 52, MODE_SENKOUSPANA,0),5);
      senkouSpanBs[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_H1, 9, 26, 52, MODE_SENKOUSPANB,0),5);    
      // check if price crossed kijun_sen line   
      if (checkLineFlip(aboveKijun_sens[i],prices[i],kijun_sens[i])){
         aboveKijun_sens[i] = !aboveKijun_sens[i];
         if(counters[i] >= reportPeriod){
            //sendAlert(currenies[i],"Base 1 hour", prices[i]);
            counters[i] = 0;
         }
      }
      // check if price crossed span A line  
      if (checkLineFlip(aboveSenkouSpanAs[i],prices[i],senkouSpanAs[i])){
         aboveSenkouSpanAs[i] = !aboveSenkouSpanAs[i];
         if(counters[i] >= reportPeriod){
            //sendAlert(currenies[i],"Span A 1 hour", prices[i]);
            counters[i] = 0;
         }
      }
      // check if price crossed span B Line  
      if (checkLineFlip(aboveSenkouSpanBs[i],prices[i],senkouSpanBs[i])){
         aboveSenkouSpanBs[i] = !aboveSenkouSpanBs[i];
         if(counters[i] >= reportPeriod){
            //sendAlert(currenies[i],"Span B 1 hour", prices[i]);
            counters[i] = 0;
         }
      }
      //4h
      kijun_sens_4h[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_H4, 9, 26, 52, MODE_KIJUNSEN,0),5);
      senkouSpanAs_4h[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_H4, 9, 26, 52, MODE_SENKOUSPANA,0),5);
      senkouSpanBs_4h[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_H4, 9, 26, 52, MODE_SENKOUSPANB,0),5);    
      // check if price crossed kijun_sen line   
      if (checkLineFlip(aboveKijun_sens_4h[i],prices[i],kijun_sens_4h[i])){
         aboveKijun_sens_4h[i] = !aboveKijun_sens_4h[i];
         if(counters_4h[i] >= reportPeriod){
            sendAlert(currenies[i],"Base 4 hour", prices[i]);
            counters_4h[i] = 0;
         }
      }
      // check if price crossed span A line  
      if (checkLineFlip(aboveSenkouSpanAs_4h[i],prices[i],senkouSpanAs_4h[i])){
         aboveSenkouSpanAs_4h[i] = !aboveSenkouSpanAs_4h[i];
         if(counters_4h[i] >= reportPeriod){
            sendAlert(currenies[i],"Span A 4 hour", prices[i]);
            counters_4h[i] = 0;
         }
      }
      // check if price crossed span B Line  
      if (checkLineFlip(aboveSenkouSpanBs_4h[i],prices[i],senkouSpanBs_4h[i])){
         aboveSenkouSpanBs_4h[i] = !aboveSenkouSpanBs_4h[i];
         if(counters_4h[i] >= reportPeriod){
            sendAlert(currenies[i],"Span B 4 hour", prices[i]);
            counters_4h[i] = 0;
         }
      }
      //24h
      kijun_sens_24h[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_D1, 9, 26, 52, MODE_KIJUNSEN,0),5);
      senkouSpanAs_24h[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_D1, 9, 26, 52, MODE_SENKOUSPANA,0),5);
      senkouSpanBs_24h[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_D1, 9, 26, 52, MODE_SENKOUSPANB,0),5);    
      // check if price crossed kijun_sen line   
      if (checkLineFlip(aboveKijun_sens_24h[i],prices[i],kijun_sens_24h[i])){
         aboveKijun_sens_24h[i] = !aboveKijun_sens_24h[i];
         if(counters_24h[i] >= reportPeriod){
            sendAlert(currenies[i],"Base 24 hour", prices[i]);
            counters_24h[i] = 0;
         }
      }
      // check if price crossed span A line  
      if (checkLineFlip(aboveSenkouSpanAs_24h[i],prices[i],senkouSpanAs_24h[i])){
         aboveSenkouSpanAs_24h[i] = !aboveSenkouSpanAs_24h[i];
         if(counters_24h[i] >= reportPeriod){
            sendAlert(currenies[i],"Span A 24 hour", prices[i]);
            counters_24h[i] = 0;
         }
      }
      // check if price crossed span B Line  
      if (checkLineFlip(aboveSenkouSpanBs_24h[i],prices[i],senkouSpanBs_24h[i])){
         aboveSenkouSpanBs_24h[i] = !aboveSenkouSpanBs_24h[i];
         if(counters_24h[i] >= reportPeriod){
            sendAlert(currenies[i],"Span B 24 hour", prices[i]);
            counters_24h[i] = 0;
         }
      }
      
      //halfh
      kijun_sens_halfh[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_M30, 9, 26, 52, MODE_KIJUNSEN,0),5);
      senkouSpanAs_halfh[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_M30, 9, 26, 52, MODE_SENKOUSPANA,0),5);
      senkouSpanBs_halfh[i] = NormalizeDouble(iIchimoku(currenies[i],
         PERIOD_M30, 9, 26, 52, MODE_SENKOUSPANB,0),5);    
      // check if price crossed kijun_sen line   
      if (checkLineFlip(aboveKijun_sens_halfh[i],prices[i],kijun_sens_halfh[i])){
         aboveKijun_sens_halfh[i] = !aboveKijun_sens_halfh[i];
         if(counters_halfh[i] >= reportPeriod){
            sendAlert(currenies[i],"Base half hour", prices[i]);
            counters_halfh[i] = 0;
         }
      }
      // check if price crossed span A line  
      if (checkLineFlip(aboveSenkouSpanAs_halfh[i],prices[i],senkouSpanAs_halfh[i])){
         aboveSenkouSpanAs_halfh[i] = !aboveSenkouSpanAs_halfh[i];
         if(counters_halfh[i] >= reportPeriod){
            sendAlert(currenies[i],"Span A half hour", prices[i]);
            counters_halfh[i] = 0;
         }
      }
      // check if price crossed span B Line  
      if (checkLineFlip(aboveSenkouSpanBs_halfh[i],prices[i],senkouSpanBs_halfh[i])){
         aboveSenkouSpanBs_halfh[i] = !aboveSenkouSpanBs_halfh[i];
         if(counters_halfh[i] >= reportPeriod){
            sendAlert(currenies[i],"Span B half hour", prices[i]);
            counters_halfh[i] = 0;
         }
      }
     
   }
}

void sendAlert(string _symbol, string _line, double _price){
   Alert("Signal! ",_line," line crossed!","TimeCurrent=",
      TimeToStr(TimeCurrent(),TIME_SECONDS),
         " Time[0]=",TimeToStr(Time[0],TIME_SECONDS),"Currency: ",
         _symbol);
      SendNotification("Signal! "+_line+ " line crossed! Currency: "+_symbol+ " Time: "+ 
      TimeToStr(TimeLocal(),TIME_SECONDS)+ " Price: "+ _price);
}

void OnTimer(){
   for(int i = 0; i < ArraySize(counters); i++){
      counters[i]++;
   }
   for(int i = 0; i < ArraySize(counters_4h); i++){
      counters_4h[i]++;
   }
   for(int i = 0; i < ArraySize(counters_24h); i++){
      counters[i]++;
   }
   for(int i = 0; i < ArraySize(counters_halfh); i++){
      counters[i]++;
   }
}

void OnDeinit(const int reason){
   Alert("Stopped");
   
}

// check if the price is above a line. true: above; false: below
bool checkLine(double _price, double _line){
   return _price >= _line;
}

// check if current crossed a line 

bool checkLineFlip(bool _currentLineStatus, double _price,
   double _line){
   if (_currentLineStatus && (!checkLine(_price, _line)))
      return true;
   if ((!_currentLineStatus) && (checkLine(_price, _line)))
      return true;
   return false;
}
