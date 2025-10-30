//  ViewController.m

#import "ViewController.h"
#import "ConsumptionManager.h"
#import "GraphView.h" // Aseguramos que la clase esté disponible para el casting

static const double kDailyConsumptionThreshold = 250.0;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:ConsumptionDataDidUpdateNotification object:nil];
    
    [self updateUI];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - IBAction
- (IBAction)registerConsumptionAction:(id)sender {
    double liters = self.litersInputTextField.doubleValue;
    
    if(liters > 0.0){
        [[ConsumptionManager sharedManager] registerConsumption:liters];
        self.litersInputTextField.stringValue = @"";
    } else {
        self.alertMessageLabel.stringValue = @"Error: Por favor, ingresa una cantidad de litros valida.";
        self.alertMessageLabel.textColor = [NSColor orangeColor];
    }
}

#pragma mark - Logica de actualizacion de la interfaz
-(void)updateUI{
    // 1. Actualizar Gráficos (Requisito 2)
    
    NSDictionary *weeklyData = [[ConsumptionManager sharedManager] getConsumptionSummaryForLastDays:7];
    NSDictionary *monthlyData = [[ConsumptionManager sharedManager] getConsumptionSummaryForLastDays:30];
    
    // Accedemos al contentView del NSBox y lo tratamos como un GraphView
    GraphView *weeklyGraphView = (GraphView *)self.weeklyGraphBox.contentView;
    weeklyGraphView.dataToDisplay = weeklyData;
    weeklyGraphView.graphTitle = @"Consumo Semanal de Agua"; // <--- TÍTULO
    weeklyGraphView.isWeekly = YES;
    
    GraphView *monthlyGraphView = (GraphView *)self.monthlyGraphBox.contentView;
    monthlyGraphView.dataToDisplay = monthlyData;
    monthlyGraphView.graphTitle = @"Consumo Mensual de Agua (30 días)"; // <--- TÍTULO
    monthlyGraphView.isWeekly = NO;
    
    
    // 2. Actualizar Alerta y Recomendación
    double totalToday = [[ConsumptionManager sharedManager] getTotalConsumptionForToday];
    
    if([[ConsumptionManager sharedManager] isConsumptionOverThresholdForToday:kDailyConsumptionThreshold]){
        self.alertMessageLabel.stringValue = [NSString stringWithFormat:@"¡ALERTA! %.1f L hoy. Has excedido el umbral de %.1f litros. ¡Reduce el consumo!", totalToday, kDailyConsumptionThreshold];
        self.alertMessageLabel.textColor = [NSColor redColor];
    }else {
        self.alertMessageLabel.stringValue = [NSString stringWithFormat:@"Consumo de hoy: %.1f L. ¡EXCELENTE! Tu meta es mantenerte bajo de %.1f litros.", totalToday, kDailyConsumptionThreshold];
        self.alertMessageLabel.textColor = [NSColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    }
    
    self.recommendationLabel.stringValue = [ConsumptionManager getWaterSavingRecommendation];
}

#pragma mark - Limpiar Datos
- (IBAction)clearDataAction:(id)sender {
    // Llamar al método de limpieza en el Manager
    [[ConsumptionManager sharedManager] clearAllConsumptionData];
    
    // Mostrar una confirmación al usuario
    self.alertMessageLabel.stringValue = @"¡Historial de consumo borrado!";
    self.alertMessageLabel.textColor = [NSColor orangeColor];
}
    

@end
