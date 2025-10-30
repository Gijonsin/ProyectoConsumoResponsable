//  GraphView.m

#import "GraphView.h"

// Constantes para el diseño
static const CGFloat PADDING = 20.0;
static const CGFloat BAR_WIDTH_RATIO = 0.6; // 60% del espacio de la barra

@implementation GraphView

// Este es el método donde se dibuja el gráfico
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Relleno de fondo (útil para verificar el área de dibujo)
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    
    if (!self.dataToDisplay || self.dataToDisplay.count == 0){
        // Muestra un mensaje si no hay datos
        NSString *noDataMessage = @"No hay datos de consumo para mostrar.";
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[NSFontAttributeName] = [NSFont systemFontOfSize:14];
        attributes[NSForegroundColorAttributeName] = [NSColor grayColor];
        
        [noDataMessage drawAtPoint:NSMakePoint(PADDING, self.bounds.size.height / 2 - 10) withAttributes:attributes];
        return;
    }
    
    // 1. Preparación de datos y escalado
    NSArray *sortedKeys = [[self.dataToDisplay allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    double maxValue = 0.0;
    for(NSNumber *value in self.dataToDisplay.allValues){
        if([value doubleValue] > maxValue){
            maxValue = [value doubleValue];
        }
    }
    if (maxValue == 0.0) maxValue = 1.0;
    
    // 2. Dimensiones de la gráfica
    NSInteger numberOfBars = sortedKeys.count;
    CGFloat graphWidth = self.bounds.size.width - 2 * PADDING;
    // CORRECCIÓN CRÍTICA: Se usa bounds.size.height para la altura
    CGFloat graphHeight = self.bounds.size.height - 2 * PADDING;
    CGFloat barSpace = graphWidth / numberOfBars;
    CGFloat barWidth = barSpace * BAR_WIDTH_RATIO;
    CGFloat currentX = PADDING + (barSpace - barWidth) / 2;
    
    // 3. Dibujar Eje Y
    [[NSColor lightGrayColor] setStroke];
    NSBezierPath *yAxis = [NSBezierPath bezierPath];
    [yAxis moveToPoint:NSMakePoint(PADDING, PADDING)];
    [yAxis lineToPoint:NSMakePoint(PADDING, graphHeight + PADDING)];
    [yAxis stroke];
    
    // 4. Iterar y dibujar cada barra
    [[NSColor colorWithRed:0.2 green:0.5 blue:1.0 alpha:1.0] setFill]; // Color de las barras (Azul)
    
    for(NSInteger i = 0; i < numberOfBars; i++){
        NSNumber *liters = self.dataToDisplay[sortedKeys[i]];
        CGFloat barHeight = ([liters doubleValue] / maxValue) * graphHeight;
        
        // Dibujar la barra
        NSRect barRect = NSMakeRect(currentX, PADDING, barWidth, barHeight);
        NSBezierPath *barPath = [NSBezierPath bezierPathWithRect:barRect];
        [barPath fill];
        
        // Dibujar la etiqueta (Fecha)
        NSString *dataLabel = sortedKeys[i];
        NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:10]};
        NSSize labelSize = [dataLabel sizeWithAttributes:attributes];
        
        // Colocar la etiqueta debajo de la barra
        [dataLabel drawAtPoint:NSMakePoint(currentX + (barWidth - labelSize.width) / 2, PADDING - labelSize.height - 2) withAttributes:attributes];
        
        currentX += barSpace;
    }
}

-(void)setDataToDisplay:(NSDictionary<NSString *,NSNumber *> *)dataToDisplay{
    _dataToDisplay = dataToDisplay;
    [self setNeedsDisplay:YES];
}

@end
