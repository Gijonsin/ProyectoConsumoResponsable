//  GraphView.m

#import "GraphView.h"

// Constantes para el diseño
static const CGFloat PADDING = 20.0;
static const CGFloat BAR_WIDTH_RATIO = 0.6;
static const double BASE_DAILY_LIMIT = 250.0;
static const double BASE_MONTHLY_LIMIT = 7500.0; // 250 L * 30 	
@implementation GraphView

// Setters para forzar el redibujo cuando se actualizan las propiedades
-(void)setDataToDisplay:(NSDictionary<NSString *,NSNumber *> *)dataToDisplay{
    _dataToDisplay = dataToDisplay;
    [self setNeedsDisplay:YES];
}

-(void)setGraphTitle:(NSString *)graphTitle{
    _graphTitle = graphTitle;
    [self setNeedsDisplay:YES];
}

-(void)setIsWeekly:(BOOL)isWeekly{
    _isWeekly = isWeekly;
    [self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    
    // 1. Mensaje de Datos Vacíos
    if (!self.dataToDisplay || self.dataToDisplay.count == 0){
        NSString *noDataMessage = @"No hay datos de consumo para mostrar.";
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[NSFontAttributeName] = [NSFont systemFontOfSize:14];
        attributes[NSForegroundColorAttributeName] = [NSColor grayColor];
        
        [noDataMessage drawAtPoint:NSMakePoint(PADDING, self.bounds.size.height / 2 - 10) withAttributes:attributes];
        return;
    }
    
    // 2. Preparación de datos y escalado
    NSArray *sortedKeys = [[self.dataToDisplay allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    // *** LÓGICA DE ESCALADO CORREGIDA ***
    // Establecer el tope base según si es semanal o mensual
    double baseLimit = self.isWeekly ? BASE_DAILY_LIMIT : BASE_MONTHLY_LIMIT;
    double maxValue = baseLimit;
    double actualMaxInArray = 0.0;
        
    for(NSNumber *value in self.dataToDisplay.allValues){
        double consumption = [value doubleValue];
        if(consumption > actualMaxInArray) {
            actualMaxInArray = consumption;
        }
    }
    
    // Si el consumo real excede el tope base, ajustamos el tope para que la barra no se salga
    if (actualMaxInArray > baseLimit) {
        maxValue = actualMaxInArray * 1.1; // 10% de margen
    }
    
    // 3. Dimensiones de la gráfica
    NSInteger numberOfBars = sortedKeys.count;
    CGFloat graphWidth = self.bounds.size.width - 2 * PADDING;
    CGFloat graphHeight = self.bounds.size.height - 3 * PADDING; // Más espacio para el título y padding superior
    
    CGFloat barSpace = graphWidth / numberOfBars;
    CGFloat barWidth = barSpace * BAR_WIDTH_RATIO;
    CGFloat currentX = PADDING + (barSpace - barWidth) / 2;
    
    // --- Atributos de texto ---
    NSMutableDictionary *labelAttributes = [NSMutableDictionary dictionary];
    labelAttributes[NSFontAttributeName] = [NSFont systemFontOfSize:10];
    labelAttributes[NSForegroundColorAttributeName] = [NSColor grayColor];
    
    // 4. Dibujar Título (NUEVO)
    if (self.graphTitle) {
        NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
        titleAttributes[NSFontAttributeName] = [NSFont boldSystemFontOfSize:14];
        titleAttributes[NSForegroundColorAttributeName] = [NSColor blackColor];
        
        // Colocar el título en la parte superior
        NSPoint titlePoint = NSMakePoint(PADDING, self.bounds.size.height - PADDING);
        [self.graphTitle drawAtPoint:titlePoint withAttributes:titleAttributes];
    }
    
    // 5. Dibujar Eje Y y Etiquetas
    // --- Eje Y ---
    [[NSColor lightGrayColor] setStroke];
    NSBezierPath *yAxis = [NSBezierPath bezierPath];
    [yAxis moveToPoint:NSMakePoint(PADDING, 2 * PADDING)];
    [yAxis lineToPoint:NSMakePoint(PADDING, graphHeight + 2 * PADDING)];
    [yAxis stroke];

    // --- Etiqueta Máxima ---
    NSString *maxLabel = [NSString stringWithFormat:@"%.0f L", maxValue];
    [maxLabel drawAtPoint:NSMakePoint(0, graphHeight + 2 * PADDING - 5) withAttributes:labelAttributes];
    
    // --- Línea y Etiqueta de Umbral (250L) ---
    // Solo dibujamos la línea de umbral si es la gráfica SEMANAL, porque el mensual tiene un tope diferente.
    if (self.isWeekly && maxValue > BASE_DAILY_LIMIT) { // <--- Ajuste de lógica de umbral
        NSString *thresholdLabel = [NSString stringWithFormat:@"%.0f L (Umbral)", BASE_DAILY_LIMIT];
        CGFloat thresholdHeight = (BASE_DAILY_LIMIT / maxValue) * graphHeight;
            
        // Dibujar línea de umbral
        [[NSColor redColor] setStroke];
        NSBezierPath *thresholdLine = [NSBezierPath bezierPath];
        [thresholdLine moveToPoint:NSMakePoint(PADDING, thresholdHeight + 2 * PADDING)];
        [thresholdLine lineToPoint:NSMakePoint(graphWidth + PADDING, thresholdHeight + 2 * PADDING)];
        [thresholdLine setLineDash: (CGFloat[]){5.0, 5.0} count:2 phase:0.0];
        [thresholdLine stroke];
            
        [thresholdLabel drawAtPoint:NSMakePoint(graphWidth + PADDING - 50, thresholdHeight + 2 * PADDING + 5) withAttributes:labelAttributes];
    }
    
    // 6. Iterar y dibujar cada barra
    [[NSColor colorWithRed:0.2 green:0.5 blue:1.0 alpha:1.0] setFill];
        
    for(NSInteger i = 0; i < numberOfBars; i++){
        NSNumber *liters = self.dataToDisplay[sortedKeys[i]];
        CGFloat barHeight = ([liters doubleValue] / maxValue) * graphHeight;
            
        // Dibujar la barra (Y inicial ajustada a 2*PADDING)
        NSRect barRect = NSMakeRect(currentX, 2 * PADDING, barWidth, barHeight);
        NSBezierPath *barPath = [NSBezierPath bezierPathWithRect:barRect];
        [barPath fill];
            
        // Dibujar el valor exacto sobre la barra
        NSString *valueLabel = [NSString stringWithFormat:@"%.1f", [liters doubleValue]];
        [valueLabel drawAtPoint:NSMakePoint(currentX + (barWidth - [valueLabel sizeWithAttributes:labelAttributes].width) / 2, barHeight + 2 * PADDING + 2) withAttributes:labelAttributes];
            
        // Dibujar la etiqueta de fecha (Eje X)
        NSString *dataLabel = sortedKeys[i];
            
        // Colocar la etiqueta debajo de la barra
        [dataLabel drawAtPoint:NSMakePoint(currentX + (barWidth - [dataLabel sizeWithAttributes:labelAttributes].width) / 2, PADDING) withAttributes:labelAttributes];
            
        currentX += barSpace;
    }
}

@end
