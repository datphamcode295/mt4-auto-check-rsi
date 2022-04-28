//+------------------------------------------------------------------+
//|                                                           V1.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+


input string symbs = "";
input bool displayRSI15 = true;
input double top = 90;
input double bottom = 10;

bool checkshowbuy[100] = {};
bool checkshowsell[100] = {};

int spacey = 35;
string sep=",";                // A separator as a character
ushort u_sep;                  // The code of the separator character
string result[];               // An array to get strings
int k ;     //num of symbols
int height = ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
int countx = 0;
int maxy = height/spacey;
int tf1 = 15, tf2 = 30, tf3 = 60;

double close[][3][5000];
int curStick[][3] ;
  

int arrsize[][3];

double temp[6];
  

int OnInit()
  {
//---
   
//---

   
   //intitial for resutl(symbol's name) array
   u_sep=StringGetCharacter(sep,0);  
   k=StringSplit(symbs,u_sep,result);
   ArrayResize(close,k);
   ArrayResize(curStick,k);
   ArrayResize(arrsize,k);
   
      //initial vale for curstik and current RSI
   for(int i = 0;i<k;i++){
      for(int j=0;j<3;j++){
         curStick[i][j]=0;
      }
      
   }
   //initial value for k symbols
   for(int n =0;n<k;n++){
         checkshowbuy[n]=False;
         checkshowsell[n]=False;
         
      arrsize[n][0] = iBars(result[n],tf1);
      arrsize[n][1] = iBars(result[n],tf2);
      arrsize[n][2] = iBars(result[n],tf3);
         
      for(int i=0;i<iBars(result[n],tf1);i++){
         close[n][0][i]= iClose(result[n],tf1,iBars(result[n],tf1)-1-i) ;
      }
      for(int i=0;i<iBars(result[n],tf2);i++){
         close[n][1][i]= iClose(result[n],tf2,iBars(result[n],tf2)-1-i) ;
      }
      for(int i=0;i<iBars(result[n],tf3);i++){
         close[n][2][i]= iClose(result[n],tf3,iBars(result[n],tf3)-1-i) ;
      }
   }
   

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      //for(int i=0,
      
      countx = 0;
            double arrForM15[5000];
      double arrForM30[5000];
      double arrForH1[5000]; 
      
     // printf(" %d ??",arrsize[0,0]);
  
   if(k>0)
     {      
           

      for(int i=0;i<k;i++){
         if(curStick[i][0]!= iBars(result[i],tf1)){
            curStick[i,0] = iBars(result[i],tf1);
            arrsize[i,0] = iBars(result[i],tf1);
            for(int j=0;j<iBars(result[i],tf1);j++){
            close[i][0][j]= iClose(result[i],tf1,iBars(result[i],tf1)-1-j);
            }
         }else{
            close[i][0][iBars(result[i],tf1)-1] = iClose(result[i],tf1,0);
         }
         if(curStick[i][1]!= iBars(result[i],tf2)){
            curStick[i][1] = iBars(result[i],tf2);
            arrsize[i,1] = iBars(result[i],tf2);
            for(int j=0;j<iBars(result[i],tf2);j++){
            close[i][1][j]= iClose(result[i],tf2,iBars(result[i],tf2)-1-j);
            }
         }else{
            close[i][1][iBars(result[i],tf2)-1] = iClose(result[i],tf2,0);
         }
         if(curStick[i][2]!= iBars(result[i],tf3)){
            curStick[i][2] = iBars(result[i],tf3);
            arrsize[i,2] = iBars(result[i],tf3);
            for(int j=0;j<iBars(result[i],tf3);j++){
            close[i][2][j]= iClose(result[i],tf3,iBars(result[i],tf3)-1-j);
            }
         }else{
            close[i][2][iBars(result[i],tf3)-1] = iClose(result[i],tf3,0);
         }
      
      
      }

      //check tung ma 1 thoa dk khong
      for(int i=0;i<k;i++){
    
      
      //int i = 0;
         threeDto1D(close,arrForM15,i,0,arrsize[i,0]);
         threeDto1D(close,arrForM30,i,1,arrsize[i,1]);   
         threeDto1D(close,arrForH1,i,2,arrsize[i,2]); 
         
         double cp15[5000];
         ArrayCopy(cp15,arrForM15,0,0);
         double cp30[5000];
         ArrayCopy(cp30,arrForM30,0,0);
         double cp60[5000];
         ArrayCopy(cp60,arrForH1,0,0);
         
         double rsim15 = iRSIOnArray(cp15,arrsize[i,0],14,0);
         double rsim30 = iRSIOnArray(cp30,arrsize[i,1],14,0);
         double rsih1 = iRSIOnArray(cp60,arrsize[i,2],14,0);
         
         //temp[i]=rsim15;
          
         //printf("::%s",result[5]);
            
         if(((i+1)%maxy)==0)
            countx++;
         if(displayRSI15)
            TextCreateCoToaDo_2(i,"Name" + string(i),result[i] + " " + DoubleToString(rsih1,4) ,"Arial",17,0,10+280*countx,spacey*(i-countx*maxy),clrAqua);

         
         if(rsih1>top&&rsim15>top&&rsim30>top&&!checkshowbuy[i])
         {
            printf("BUY (h1,m30,m15>%f) %s",top,result[i]);
            printf("h1: %f, m30: %f, m15: %f",rsih1,rsim30,rsim15);
            checkshowbuy[i] = true;
            checkshowsell[i] = false;
            Alert("Buy (h1:%f,m30:%f,m15:%f>%f)",rsih1,rsim30,rsim15,top, result[i]);
         }
      
         if(rsih1<bottom&&rsim15<bottom&&rsim30<bottom&&!checkshowsell[i])
         {
            printf("SELL (h1,m30,m15 < %f)%s %f",bottom,result[i],rsim15);
            checkshowbuy[i] = false;
            checkshowsell[i] = true;
     
            Alert("SEll (h1:%f,m30:%f,m15:%f<%f)",rsih1,rsim30,rsim15,bottom, result[i]);
         }
      
         if((rsih1<top&&rsih1>bottom)||(rsim15<top&&rsim15>bottom)||(rsim30<top&&rsim30>bottom))
         {            
           checkshowbuy[i] = false;
           checkshowsell[i] = false;   
         }
         
         

      
  } 
      
    
   
  }}
//+------------------------------------------------------------------+
//---


void threeDto1D(double& src[][][], double& des[], int firstindex, int secondindex, int length){
   for(int i = 0; i<length;i++){
      des[i] = src[firstindex][secondindex][i];
   }
}


string NenTangNenGiam(int thutunen)
{
   string Maunen = "";
   if(Open[thutunen] > Close[thutunen]) Maunen = "NenGiam";
   if(Open[thutunen] <= Close[thutunen]) Maunen = "NenTang";
   return Maunen;
}
void TextCreateCoToaDo_2(const long              chart_ID=0,               // chart's ID
                         const string            name="Text",              // object name
                         const string            text_ShowScreen="Text",              // the text itself
                         const string            font="Arial",             // font
                         const int               font_size=17,             // font size
                         int Pos_Screen            = 0,
                         int value_x               = 0,                  // toa do x
                         int value_y               =  0,  
                         const color             clr=clrBlue,               // color
                         const double            angle=0.0,                // text slope
                         const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                         datetime                time=0,                   // anchor point time
                         double                  price=0,                  // anchor point price
                         const int               sub_window=0,             // subwindow index
                         const bool              back=false,               // in the background
                         const bool              selection=true,          // highlight to move
                         const bool              hidden=true,              // hidden in the object list
                         const long              z_order=0)                // priority for mouse click
{
            ObjectCreate(name,OBJ_LABEL,0,0,0);
            ObjectSetText(name,text_ShowScreen,font_size,"Arial",clr);
            ObjectSet(name,OBJPROP_CORNER,Pos_Screen);
            ObjectSet(name,OBJPROP_XDISTANCE,value_x);
            ObjectSet(name,OBJPROP_YDISTANCE,value_y);
            
}