//  ConsumptionManager.m

#import "ConsumptionManager.h"

static const double kDailyConsumptionThreshold = 250.0;
NSString *const ConsumptionDataDidUpdateNotification = @"ConsumptionDataDidUpdateNotification";
static NSString *const kConsumptionDataKey = @"WaterConsumptionEntries";

@implementation ConsumptionManager

#pragma mark - Singleton e Inicializacion

+(instancetype)sharedManager{
    static ConsumptionManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc]init];
        [sharedManager loadEntries];
    });
    return sharedManager;
}

-(instancetype) init{
    self = [super init];
    if(self){
        _allConsumptionEntries = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Registro de consumo
-(void)registerConsumption:(double)liters{
    
    // 1. Inicializar variables
    WaterConsumptionEntry *entryToUpdate = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // 2. Buscar una entrada existente para hoy
    for (WaterConsumptionEntry *entry in self.allConsumptionEntries) {
        // isDateInToday es más seguro que solo comparar fechas
        if ([calendar isDateInToday:entry.date]) {
            entryToUpdate = entry;
            break;
        }
    }
    
    if (entryToUpdate) {
        // 3. Si existe, sumar el nuevo consumo al valor existente (Acumulación)
        entryToUpdate.litersConsumed += liters;
    } else {
        // 4. Si no existe, crear una nueva entrada
        WaterConsumptionEntry *newEntry = [[WaterConsumptionEntry alloc] initWithLiters:liters onDate:[NSDate date]];
        [self.allConsumptionEntries addObject:newEntry];
    }
    
    // 5. Opcional: Asegurar que la lista esté ordenada por si fue insertado un nuevo elemento
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [self.allConsumptionEntries sortUsingDescriptors:@[sortDescriptor]];

    // 6. Guardar y notificar a la interfaz
    [self saveEntries];
    [[NSNotificationCenter defaultCenter]postNotificationName:ConsumptionDataDidUpdateNotification object:nil];
}

#pragma mark - Persistencia de Datos
-(void)saveEntries{
    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.allConsumptionEntries requiringSecureCoding:YES error:&error];
    
    if(data && !error){
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kConsumptionDataKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSLog(@"Error al guardar datos %@",error.localizedDescription);
    }
}

-(void)loadEntries{
    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:kConsumptionDataKey];
    if(data){
        NSError *error = nil;
        NSSet *allowedClasses = [NSSet setWithObjects:[NSArray class], [WaterConsumptionEntry class], [NSDate class], nil];
        
        NSArray<WaterConsumptionEntry *> *loadedEntries = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:data error:&error];
        if(loadedEntries && !error){
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
            [self.allConsumptionEntries setArray:[loadedEntries sortedArrayUsingDescriptors:@[sortDescriptor]]];
            
        } else {
            NSLog(@"Error al cargar los datos %@", error.localizedDescription);
        }
    }
}

-(double)getTotalConsumptionForToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    double totalToday = 0.0;
    
    for(WaterConsumptionEntry *entry in self.allConsumptionEntries){
        if([calendar isDateInToday:entry.date]){
            totalToday += entry.litersConsumed;
        }
    }
    return  totalToday;;
}

-(BOOL)isConsumptionOverThresholdForToday:(double)threshold{
    return [self getTotalConsumptionForToday] >= threshold;
}

#pragma mark - Graficos (Generación de datos)
- (NSDictionary<NSString *,NSNumber *> *)getConsumptionSummaryForLastDays:(NSInteger)days{
    NSMutableDictionary *summary = [NSMutableDictionary dictionary];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *today = [calendar startOfDayForDate:[NSDate date]];
    
    NSDateComponents *offset = [[NSDateComponents alloc]init];
    offset.day = -(days - 1);
    NSDate *startDate = [calendar dateByAddingComponents:offset toDate:today options:0];
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"dd/MM"];
    
    for(WaterConsumptionEntry *entry in self.allConsumptionEntries){
        if([entry.date compare:startDate] != NSOrderedAscending) {
            NSString *dayKey = [dayFormatter stringFromDate:entry.date];
            
            double currentTotal = [summary[dayKey] doubleValue];
            summary[dayKey] = @(currentTotal + entry.litersConsumed);
        }
    }
    
    return [summary copy];
}

+(NSString *)getWaterSavingRecommendation {
    NSArray *recommendations = @[
        @"Revisa y repara las fugas en grifos y tuberias, pueden ahorrar cientos de litros al dia!",
        @"Cierra el grifo mientras te cepillas los dientes o te afeitas.",
        @"Ducha corta: Intenta no durar mas de 5 minutos en la ducha.",
        @"Utiliza la lavadora y el lavavajillas solo cuando esten completamente llenos.",
        @"Recoge el agua de lluvia para regar las plantas o limpiar el patio."
    ];
    
    return recommendations[arc4random_uniform((u_int32_t)recommendations.count)];
}

@end
